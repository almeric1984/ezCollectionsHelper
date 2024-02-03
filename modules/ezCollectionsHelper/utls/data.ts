import { Common } from "./common";
/** @customName GetRealmID */
declare function FixGetRealmID(this: void): number;
/** @customName AuthDBQuery */
declare function FixAuthDBQuery(this: void, query : string): ElunaQuery;

export class Data {
    public skinCollectionCache: {[id: number]: Common.SkinCollectionList }  = {};
    public camaraCache: {[id: number]: Common.Camera }  = {};
    private camaraQuery = "select id, `option`, race, sex, x,y,z,f, anim, name,class,subclass from custom_ezCollectionsHelperCameras;"
    private transmogQuery =
    `SELECT custom_transmogrification.GUID, FakeEntry, item_instance.itemEntry FROM custom_transmogrification
	INNER JOIN item_instance ON custom_transmogrification.GUID = item_instance.guid
	WHERE \`owner\` = %d`; // %d is the player guid

    private accountQuery =
    `SELECT item_template_id FROM custom_unlocked_appearances WHERE account_id = %d`; // %d is the account id

    private outfitAddQuery = `INSERT INTO custom_transmogrification_sets (Owner, PresetID, SetName, SetData) VALUES(%d, %d, '%s', '%s')`
    private outfitQuery = "select PresetID, SetName, SetData from custom_transmogrification_sets where Owner = %d";
    private outfitDeleteQuery = "DELETE FROM custom_transmogrification_sets WHERE Owner = %d AND PresetID = %d";
    private outfitUpdateQuery = "UPDATE custom_transmogrification_sets SET SetName = '%s', SetData = '%s' WHERE Owner = %d AND PresetID = %d";
    private outfitRenameQuery = "UPDATE custom_transmogrification_sets SET SetName = '%s' WHERE Owner = %d AND PresetID = %d";
    private lowestIndexOfOutfitQuery = `
    SELECT MIN(MissingPresetId) AS LowestMissingPresetId
    FROM (
        SELECT MIN(PresetId) + 1 AS MissingPresetId
        FROM custom_transmogrification_sets t1
        WHERE NOT EXISTS (
            SELECT 1
            FROM custom_transmogrification_sets t2
            WHERE t2.PresetId = t1.PresetId + 1 AND \`owner\` = %d
        )
        UNION
        SELECT 
            CASE
                WHEN (SELECT MIN(PresetId) FROM custom_transmogrification_sets WHERE \`owner\` = %d) >= 1 THEN
                    (SELECT MIN(PresetId) - 1 FROM custom_transmogrification_sets WHERE \`owner\` = %d)
                ELSE
                    null
            END AS MissingPresetId
    ) AS MissingPresets;`

    private itemsQuery = `SELECT entry, InventoryType, Material, AllowableClass, AllowableRace, name, VerifiedBuild, Quality, SellPrice, class, subclass
        FROM item_template where InventoryType > 0 AND InventoryType < 20 AND entry <> 5106 AND 
        FlagsExtra <> 8192 AND
        FlagsExtra <> 6299648 AND
        LOWER(name) NOT LIKE "%%test %%" AND
        LOWER(name) NOT LIKE "%%npc equip%%"; `
    private ConfigQuery = `SELECT Prefix,Version, CacheVersion, ModulesConfPath FROM custom_ezCollectionsHelperConfig where RealmID = %d;`
    private weaponSlotQuery = `SELECT slot FROM character_inventory WHERE item = %d`

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

    public GetConfig() {
        let queryString = string.format(this.ConfigQuery, FixGetRealmID())
        let query = FixAuthDBQuery(queryString);    
        do {
            Common.Settings.addonPrefix = query.GetString(0);
            Common.Settings.addonVersion = query.GetString(1);
            Common.Settings.addonCacheVersion = query.GetString(2);
            Common.Settings.ModulesConfPath = query.GetString(3);
        } while(query.NextRow())
    }

    public ApplyTransmog(playerGuid: number, itemGuid: number, fakeEntry: number) : boolean {
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
    //ezCollections.Cache.Cameras[option * ezCollections.CameraOptionsToCameraID[ezCollections.CameraOptions[1]] + race * ezCollections.RaceToCameraID.Human + sex * ezCollections.SexToCameraID[1] + id] 
    private GetCamaraId(option: number, race: number, sex :number, id : number ){

        return (option * 10000000) + (race * 100000) + (sex * 10000) + id
    }
    public BuildCameraCache() {
        let queryResult = FixAuthDBQuery(string.format(this.camaraQuery));
        if(queryResult) {   
            do {
                let camera = new Common.Camera();
                camera.Id = queryResult.GetInt32(0);
                camera.Option = queryResult.GetInt32(1);
                camera.Race = queryResult.GetInt32(2);
                camera.Sex = queryResult.GetInt32(3);
                camera.X = queryResult.GetFloat(4);
                camera.Y = queryResult.GetFloat(5);
                camera.Z = queryResult.GetFloat(6);
                camera.F = queryResult.GetFloat(7);
                camera.Anim = queryResult.GetInt32(8);
                camera.Name = queryResult.GetString(9);
                camera.Class = queryResult.GetInt32(10);
                camera.SubClass = queryResult.GetInt32(11);
                this.camaraCache[this.GetCamaraId(camera.Option, camera.Race,camera.Sex, (camera.Class * 100 + camera.SubClass))] = camera;
            } while (queryResult.NextRow());
        }
    }
    public GetOutfits(playerGuid: number) : Common.Outfit[] {
        let result = [];
        let queryResult = CharDBQuery(string.format(this.outfitQuery, playerGuid));
        if (queryResult) {
            do {
                let outfit = new Common.Outfit();
                outfit.Id = queryResult.GetInt32(0);
                outfit.Name = queryResult.GetString(1);
                outfit.Data = queryResult.GetString(2);
                result.push(outfit);
            } while (queryResult.NextRow());
        }
        return result;
    }
    public AddOutfit(guid: number, outfitName : string, data: string) : number
    {
        let lowestIndexQuery = CharDBQuery(string.format(this.lowestIndexOfOutfitQuery, guid,guid,guid));
        let lowestIndex = -1;
        do {
            lowestIndex = lowestIndexQuery.GetInt32(0);
            
        } while(lowestIndexQuery.NextRow());
        if(lowestIndex != -1)
        {
            CharDBQuery(string.format(this.outfitAddQuery, guid, lowestIndex, outfitName, data));
        }
        return lowestIndex;
    }
    public RenameOutfit(guid: number, outfitId: number, outfitName : string) : boolean
    {
        CharDBQuery(string.format(this.outfitRenameQuery, outfitName, guid, outfitId));
        return true;
    }
    public UpdateOutfit(guid: number, outfitId: number, outfitName : string, data: string) : boolean
    {
        CharDBQuery(string.format(this.outfitUpdateQuery, outfitName, data, guid, outfitId));
        return true;
    }
    public DeleteOutfit(guid: number, outfitId: number) : boolean
    {
        CharDBQuery(string.format(this.outfitDeleteQuery, guid, outfitId));
        return true;
    }
    
    public GetCameraList() : Common.Camera[]  {
        let result = [];
        for (let key of Object.keys(this.camaraCache)) {
            let camera = this.camaraCache[key];
            result.push(camera);
        }
        return result;
    }
    public GetSkinCollectionList() : {[id: number]: Common.SkinCollectionList } {
        let result = {};
        let queryResult = WorldDBQuery(string.format(this.itemsQuery));
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
                skinCollectionList.Quality = queryResult.GetInt32(7);
                skinCollectionList.SellPrice = queryResult.GetInt32(8);
                skinCollectionList.Class = queryResult.GetInt32(9);
                skinCollectionList.SubClass = queryResult.GetInt32(10);
                if(Common.Settings.AllowedQuality(skinCollectionList.Quality))
                {
                    if(skinCollectionList.RaceMask == -1)
                        skinCollectionList.RaceMask = 32767;
                    result[skinCollectionList.Id] = skinCollectionList;
                }
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
                //Update hidden fake id to 15
                if(skinsOwned.FakeEntry == 1)
                    skinsOwned.FakeEntry = 15;
                skinsOwned.RealEntry = queryResult.GetInt32(2);
                skinsOwned.Slot = 0;
                if(this.skinCollectionCache[skinsOwned.RealEntry] !== undefined) {
                    // If shield or weapon pull from database and figure out what slot its in
                    if(this.skinCollectionCache[skinsOwned.RealEntry].Class == 2 || (this.skinCollectionCache[skinsOwned.RealEntry].Class == 4 && this.skinCollectionCache[skinsOwned.RealEntry].SubClass == Common.ArmorTypes.SHIELD))   
                    {
                        let weaponSlotQuery = CharDBQuery(string.format(this.weaponSlotQuery, skinsOwned.GUID));
                        if (weaponSlotQuery) {
                            do {
                                skinsOwned.Slot = weaponSlotQuery.GetInt32(0) + 1;
                            } while (weaponSlotQuery.NextRow());
                        }
                    }
                    else
                    {
                        skinsOwned.Slot = this.skinCollectionCache[skinsOwned.RealEntry].Slot;
                    }
                    result.push(skinsOwned);
                }
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

    public SearchAppearances(query: string, slot : string, accountId : number) : any[]
    {
        let result = [];
        //Search Collections
        for (let key of Object.keys(this.skinCollectionCache)) {
            let skinCollection = this.skinCollectionCache[key];
            if(skinCollection.Slot != Common.GetInventorySlotId(slot)){
                // TODO Clean this up
                if(slot == "SHIELD" || (slot == Common.GetWeaponTypeNameById(skinCollection.SubClass) && skinCollection.Class == 2))
                {

                }
                else
                {
                    continue;
                }
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

    public PackSkinCollectionList(slot : string, player: Player) : string[] {
        let result = [];
        for (let key of Object.keys(this.skinCollectionCache)) {
            let skinCollection = this.skinCollectionCache[key];
            let data = `${skinCollection.Id}`;
            let camera = 0;
            let cameraId = this.GetCamaraId(1,  player.GetRace(), player.GetGender(), ( skinCollection.Class * 100 + skinCollection.SubClass ));
            // Try to get the camera from the cache if it exists
            if(this.camaraCache[cameraId] !== undefined)
            {
                camera = cameraId
            }
                // If that fails try to get the camera from cache using all races, all genders
            else
            {   
                cameraId = this.GetCamaraId(1,  30, 3, ( skinCollection.Class * 100 + skinCollection.SubClass ));
                if(this.camaraCache[cameraId] !== undefined)
                {
                    camera = cameraId
                }
            }

            //Handles Common Armor
            if(skinCollection.Slot == Common.GetInventorySlotId(slot)) {
                data = this.BuildSkinCollectionString(skinCollection, data, slot,camera);
                result.push(data);
            }
            //Handles Weapons and Shields
            else if(Common.GetInventorySlotId(slot) == 0)
            {
                if(slot == "SHIELD" && skinCollection.Class == 4 && skinCollection.SubClass == Common.ArmorTypes.SHIELD)
                {
                    data = this.BuildSkinCollectionString(skinCollection, data, slot,camera);
                    result.push(data);
                }
                else if(slot == Common.GetWeaponTypeNameById(skinCollection.SubClass) && skinCollection.Class == 2) 
                {
                    data = this.BuildSkinCollectionString(skinCollection, data, slot, camera, true);
                    result.push(data);
                }
            }
        }
        return result;
    }
    
    private BuildSkinCollectionString(skinCollection: any, data: string, slot: string, camera : number , weapon: boolean = false) {
        let classMask = Data.IntToHexClass(skinCollection.ClassMask);
        let raceMask = Data.IntToHexRace(skinCollection.RaceMask);
        data = `${data}I${Common.GetInventorySlotId(slot)}`;
        // if(skinCollection.QuestIds.length > 0)
        //     data = `${data}Q${skinCollection.QuestIds.join('Q')}`;
        data = `${data}Q123`;
        data = `${data}B15990`;
        if(weapon)
        {
            data = `${data}W`;
        }
        if(camera != 0)
            data = `${data}C${camera}`;
        // if(skinCollection.BossIds.length > 0)
        //     data = `${data}B${skinCollection.BossIds.join('B')}`;
        // if(skinCollection.Camra != "")
       // data = `${data}C0`;
        // if(skinCollection.Unuseable)
        //     data = `${data}U` ;
        // if(skinCollection.Unobtainable)
        //     data = `${data}O`;
        /// Add Enchantable E and is weapon W later
        data = `${data}A${Common.MaterialToArmorType(skinCollection.Type)}`;
        let sourceMask = this.toHex(Common.SourceMask.None);
        data = `${data}S${sourceMask}`;
        //data = `${data}S${skinCollection.SourceMask}`;
        data = `${data}L${classMask}`;
        data = `${data}R${raceMask}`;
        //data = `${data}R${skinCollection.RaceMask}`;
        //data = `${data}T${skinCollection.Icon}`;
        // Add Expansion X = WOTLK x = BC none = classic later
        return data;
    }

    toHex(number: number): string {
        if(number < 0) {
            return "-" + string.format("%02X", number * -1)
        }
        else
        {
            return string.format("%02X", number)
        }
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