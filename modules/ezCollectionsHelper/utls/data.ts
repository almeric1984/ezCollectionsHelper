import { Common } from "./common";
export class Data {
    private skinCollectionCache: {[id: number]: Common.SkinCollectionList }  = {};
    private transmogQuery =
    `SELECT custom_transmogrification.GUID, FakeEntry, item_instance.itemEntry FROM custom_transmogrification
	INNER JOIN item_instance ON custom_transmogrification.GUID = item_instance.guid
	WHERE \`owner\` = %d`; // %d is the player guid

    private accountQuery =
    `SELECT item_template_id FROM custom_unlocked_appearances WHERE account_id = %d`; // %d is the account id

    private itemsQuery = `SELECT entry, InventoryType, Material, AllowableClass, AllowableRace, name, VerifiedBuild
        FROM item_template where InventoryType > 0 AND InventoryType < 20 AND entry <> 5106 AND 
        FlagsExtra <> 8192 AND
        FlagsExtra <> 6299648 AND
        LOWER(name) NOT LIKE "%%test %%" AND
        Quality >= %d AND
        Quality <= %d 
         ; `
        
    // private itemsQuery =
    // `SELECT DISTINCT entry, InventoryType, Material, AllowableClass, AllowableRace, name, VerifiedBuild
    //     FROM (
    //         SELECT it.entry, it.InventoryType, it.Material, it.AllowableClass, it.AllowableRace, it.name, it.VerifiedBuild
    //         FROM item_template AS it
    //         WHERE it.InventoryType <> 0  AND entry <> 5106
    //         AND EXISTS (SELECT 1 FROM npc_vendor AS nv WHERE it.entry = nv.item)

    //         UNION ALL

    //         SELECT it.entry, it.InventoryType, it.Material, it.AllowableClass, it.AllowableRace, it.name, it.VerifiedBuild
    //         FROM item_template AS it
    //         WHERE it.InventoryType <> 0 AND entry <> 5106
    //         AND EXISTS (SELECT 1 FROM creature_loot_template AS clt WHERE it.entry = clt.item)
    //     ) AS combined_results;`

    private applyTransmogQuery = 'INSERT INTO custom_transmogrification (GUID, FakeEntry, Owner) VALUES(%d, %d, %d) ON DUPLICATE KEY UPDATE FakeEntry = %d';
    private removeTransmogQuery = 'DELETE FROM custom_transmogrification where Owner = %d AND GUID = %d ';

    public ApplyTransmog(playerGuid: number, itemGuid: number, fakeEntry: number) : boolean {
        print(string.format(this.applyTransmogQuery, itemGuid, fakeEntry, playerGuid, fakeEntry))
        CharDBQuery(string.format(this.applyTransmogQuery, itemGuid, fakeEntry, playerGuid, fakeEntry));
        return true
    }

    public DeleteTransmog(playerGuid: number, itemGuid: number) : boolean {
        CharDBQuery(string.format(this.removeTransmogQuery, playerGuid, itemGuid));
        return true
    }
    public CleanTransmogDb(playerGuid: number)  {
        this.GetCurrentTransmog(playerGuid).forEach((transmog) => {
            if(transmog.FakeEntry == transmog.RealEntry)
            {
                this.DeleteTransmog(playerGuid, transmog.GUID)
            }
        });
        return true;
    }
    public GetSkinCollectionList() : {[id: number]: Common.SkinCollectionList } {
        let result = {};
        let queryResult = WorldDBQuery(string.format(this.itemsQuery, Common.Settings.MinQuality, Common.Settings.MaxQuality));
        if (queryResult) {
            do {
                let skinCollectionList = new Common.SkinCollectionList();
                skinCollectionList.Id = queryResult.GetInt32(0);
                skinCollectionList.Slot = queryResult.GetInt32(1);
                skinCollectionList.Type = queryResult.GetInt32(2);
                skinCollectionList.ClassMask = queryResult.GetInt32(3);
                skinCollectionList.RaceMask = queryResult.GetInt32(4);
                skinCollectionList.Name = queryResult.GetString(5);
                skinCollectionList.VerifiedBuild = queryResult.GetInt32(6);
                if(skinCollectionList.RaceMask == -1)
                    skinCollectionList.RaceMask = 32767;
                result[skinCollectionList.Id] = skinCollectionList;
            } while (queryResult.NextRow());
        }
        this.skinCollectionCache = result;
        return result;
    }

    public GetCurrentTransmog(playerGuid: number) : Common.SkinsOwned[] {
        if(Object.keys(this.skinCollectionCache).length == 0) {
            return [];
        }
        let result = [];
        let queryResult = CharDBQuery(string.format(this.transmogQuery, playerGuid));
        if (queryResult) {
            do {
                let skinsOwned = new Common.SkinsOwned();
                skinsOwned.GUID = queryResult.GetInt32(0);
                skinsOwned.FakeEntry = queryResult.GetInt32(1);
                skinsOwned.RealEntry = queryResult.GetInt32(2);
                skinsOwned.Slot = 0;
                if(this.skinCollectionCache[skinsOwned.RealEntry] !== undefined) {
                    skinsOwned.Slot = this.skinCollectionCache[skinsOwned.RealEntry].Slot;
                }
                result.push(skinsOwned);
            } while (queryResult.NextRow());
        }
        return result;
    }

    public GetAccountUnlockedAppearances(accountId: number) : number[] {
        let result = [];
        let queryResult = CharDBQuery(string.format(this.accountQuery, accountId));
        if (queryResult) {
            do {
                result.push(queryResult.GetInt32(0));
            } while (queryResult.NextRow());
        }
        return result;
    }

    public SearchAppearances(query: string, slot : number, accountId : number) : any[]
    {
        let result = [];
        //Search Collections
        for (let key of Object.keys(this.skinCollectionCache)) {
            let skinCollection = this.skinCollectionCache[key];
            if(skinCollection.Slot != slot){
                continue;
            }
            if((query.length === 0 || query === undefined))
            {
                result.push(skinCollection.Id);
            }
            else
            {
                if(query.length < 3)
                    return result;
                if(skinCollection.Slot == slot && skinCollection.Name.toLowerCase().includes(query.toLowerCase())) {
                    result.push(skinCollection.Id);
                }
            }
        }

        return result;
    }

    public PackSkinCollectionList(slot : string) : string[] {
        let result = [];
        for (let key of Object.keys(this.skinCollectionCache)) {
            let skinCollection = this.skinCollectionCache[key];
            let data = `${skinCollection.Id}`;
           // print(skinCollection.Slot + " = " + Common.GetInventorySlotId(slot))
            if(skinCollection.Slot == Common.GetInventorySlotId(slot)) {
                let classMask = Data.IntToHexClass(skinCollection.ClassMask);
                let raceMask = Data.IntToHexRace(skinCollection.RaceMask);
                data = `${data}I${Common.GetInventorySlotId(slot)}`;
                // if(skinCollection.QuestIds.length > 0)
                //     data = `${data}Q${skinCollection.QuestIds.join('Q')}`;
                data = `${data}Q123`;
                data = `${data}B15990`;
                data = `${data}C5`;
                // if(skinCollection.BossIds.length > 0)
                //     data = `${data}B${skinCollection.BossIds.join('B')}`;
                // if(skinCollection.Camra != "")
                //     data = `${data}C${skinCollection.Camra}`;
                // if(skinCollection.Unuseable)
                //     data = `${data}U` ;
                // if(skinCollection.Unobtainable)
                //     data = `${data}O`;
                /// Add Enchantable E and is weapon W later
                data = `${data}A${Common.MaterialToArmorType(skinCollection.Type)}`;
                data = `${data}S0B`;
                //data = `${data}S${skinCollection.SourceMask}`;
                data = `${data}L${classMask}`;
                data = `${data}R${raceMask}`;
                //data = `${data}R${skinCollection.RaceMask}`;
                //data = `${data}T${skinCollection.Icon}`;
                // Add Expansion X = WOTLK x = BC none = classic later
                result.push(data);
            }
        }
        return result;
    }


    private static IntToHexClass(value: number): string {
        // Corrects for any class flag
        if(value == 32767 || value == 262143)
            value = -1
        // Corrects for rogue class flag issue
        if(value == 31240)
            value = 8
        let isNegative = value < 0;
        if(isNegative) {
            value = value * -1;
        }
        let hexstring = string.format("%X", value);
        if (isNegative) {
            hexstring = "-" + hexstring;
        }
        return hexstring;
    }

    private static IntToHexRace(value: number): string {
        let flags = this.generateFlags(value);
        let newValue = this.convertFlagsToInt(flags);
        let isNegative = newValue < 0;
        if(isNegative) {
            value = value * -1;
        }
        let hexstring = string.format("%02X", newValue);

        if(isNegative) {
            hexstring = "-" + hexstring;
        }
        return hexstring;
    }

    //Functions below are to strip Custom Races
    private static generateFlags(value: number): string[] {
        let flags: string[] = [];

        for (let i = Common.RaceData.length - 1; i >= 0; i--) {
            const { id, name } = Common.RaceData[i];
            if (value >= id) {
                value -= id;
                flags.push(name);
            }
        }

        return flags;
    }

    public static convertFlagsToInt(flags: string[]): number {
        let value = 0;
        for (const flagName of flags) {
            for (const data of Common.RaceData) {
                const { id, name } = data;
                if (name === flagName) {
                    value += id;
                    break;
                }
            }
        }

        return value;
    }
}