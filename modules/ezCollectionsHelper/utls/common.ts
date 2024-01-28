
export namespace Common {

    export class Settings {
        public static addonPrefix = "ezCollections";
        public static addonVersion = "2.4.4";
        public static addonCacheVersion = "nocache";
        public static ModulesConfPath = "etc/modules";
        public static Config : TransmogrificationConfig;

        public static AllowedQuality(quality: number) : boolean {
            if(quality == Quality.Poor && this.Config.AllowPoor == 1)
                return true;
            if(quality == Quality.Common && this.Config.AllowCommon == 1)
                return true;
            if(quality == Quality.Uncommon && this.Config.AllowUncommon == 1)
                return true;
            if(quality == Quality.Rare && this.Config.AllowRare == 1)
                return true;
            if(quality == Quality.Epic && this.Config.AllowEpic == 1)
                return true;
            if(quality == Quality.Legendary && this.Config.AllowLegendary == 1)
                return true;    
            if(quality == Quality.Artifact && this.Config.AllowArtifact == 1)
                return true;
            if(quality == Quality.Heirloom && this.Config.AllowHeirloom == 1)
                return true;

            return false;
        }
    }

    export type RaceFlag = {
        id: number;
        name: string;
    };

    export class SearchQuery {
        type: number;
        token: number;
        slot: string;
        query: string;
        slotIndex: number;
        entry: number;
        unknown: number;
    }

    export enum SourceMask {
        None = 0,
        BossDrop = 1,
        Query = 2,
        Vendor = 4,
        WorldDrop = 8,
        Achievement = 16,
        Profession = 32,
        Store = 64,
        Subscription = 128,
        
    }

    export function DataToSearchQuery(data : string[]) : SearchQuery {
        let query = new SearchQuery()
        query.type = tonumber(data[0])
        query.token = tonumber(data[1])
        query.slot = data[2]
        query.query = data[3]
        let subquery = data[4].split(",")
        query.slotIndex = this.GetInventorySlotName(query.slot)
        //query.slotIndex = tonumber(subquery[0])
        query.entry = tonumber(subquery[1])
        query.unknown = tonumber(subquery[2])
        return query
    }

    export const RaceData: RaceFlag[] = [
        { id: 1, name: "Human" },
        { id: 2, name: "Orc" },
        { id: 4, name: "Dwarf" },
        { id: 8, name: "Night Elf" },
        { id: 16, name: "Undead" },
        { id: 32, name: "Tauren" },
        { id: 64, name: "Gnome" },
        { id: 128, name: "Troll" },
        { id: 512, name: "Blood Elf" },
        { id: 1024, name: "Draenei" }
    ];

    export enum Quality {
        Poor = 0,
        Common = 1,
        Uncommon = 2,
        Rare = 3,
        Epic = 4,
        Legendary = 5,
        Artifact = 6,
        Heirloom = 7
    }

    export enum InventorySlots
    {
        HEAD        = 1,
        NECK        = 2,
        SHOULDER    = 3,
        SHIRT       = 4,
        CHEST       = 5,
        WAIST       = 6,
        LEGS        = 7,
        FEET        = 8,
        WRIST       = 9,
        HANDS       = 10,
        FINGER      = 11,
        TRINKET     = 12,
        ONEHAND     = 13,
        SHIELD      = 14,
        RANGE       = 15,
        BACK        = 16,
        TWO_HAND    = 17,
        BAG         = 18,
        TABARD      = 19,        
    }
    export enum ArmorTypes 
    {
        "CLOTH" = 1,
        "LEATHER" = 2,
        "MAIL" = 3,
        "PLATE" = 4,
        "SHIELD" = 6,
    }
    export enum WeaponTypes 
    {
        "1H_AXE" = 0,
        "2H_AXE" = 1,
        "BOW" = 2,
        "GUN" = 3,
        "1H_MACE" = 4,
        "2H_MACE" = 5,
        "POLEARM" = 6,
        "1H_SWORD" = 7,
        "2H_SWORD" = 8,
        "STAFF" = 10,
        "FIST" = 13,
        "MISC" = 14,
        "DAGGER" = 15,
        "THROWN" = 16,
        "SPEAR" = 17,
        "CROSSBOW" = 18,
        "WAND" = 19,
        "FISHING_POLE" = 20,
    }

    export function GetInventorySlotId(slotName: string) : number {
        if(!InventorySlots[slotName.toUpperCase()]) {
            return 0;
        }
        return InventorySlots[slotName.toUpperCase()] 
    }
    export function GetWeaponTypeNameById(weaponType: number) : string {
        if(!WeaponTypes[weaponType]) {
            return "UNKNOWN";
        }
        return WeaponTypes[weaponType]
    }   
    export function GetInventorySlotName(slotId: number) : string {
        if(!InventorySlots[slotId]) {
            return "UNKNOWN";
        }
        return InventorySlots[slotId]
    }
    export function MaterialToArmorType(material: number) : number {
        switch(material) {
            case 7: 
                return 1;
            case 6: 
                return 4;
            case 5: 
                return 3;
            default:
                return 2;
        }
    }

    export class Request {
        command: string;
        subCommand: string;
        data: string | string[];
        constructor(message: string) {
            let [command, subCommand, ...data] = message.split(':');
            this.command = command;
            if(subCommand) {
                this.subCommand = subCommand;
            }
            if(data) {
                if(data.length == 1) {
                    this.data = data[0];
                } else {
                    this.data = data;
                }
            }
        }
    }
    export class SkinsOwned {
        public GUID: number;
        public RealEntry: number;
        public FakeEntry: number;
        public Slot: number;
    }
    export class Camera {
        public Id: number;
        public Name: string;
        public Anim: number;
        public Option: number;
        public Race : number;
        public Sex : number;
        public X: number;
        public Y: number;
        public Z: number;
        public F: number;
        public Class: number;
        public SubClass: number;
    }
    export class SkinCollectionList {
        public Id: number;
        public Name: string;
        public Description: string;
        public Icon: string = "";
        public Camra: string = "";
        public Type: number;
        public Slot: number;
        public SourceMask : number =0 ;
        public RaceMask : number =0 ;
        public ClassMask : number =0 ;
        public VerifiedBuild: number;
        public QuestIds: number[];
        public BossIds: number[];
        public Unobtainable: boolean;
        public Unuseable: boolean;
        public Holiday: number
        public Quality: number;
        public SellPrice: number;
        public Class: number;
        public SubClass: number;
    }

    export function LoadConfig() : TransmogrificationConfig{

        let result = new TransmogrificationConfig();
        let [file] = io.open(Common.Settings.ModulesConfPath + "/transmog.conf", "r");
        let contents = [];
        if(file == null)
        {
            [file] = io.open(Common.Settings.ModulesConfPath + "/transmog.conf.dist", "r");
            if(file == null)
            {
                print("Error: Could not load config file")
                return;
            }
        }
        let section = "";
        for(let [line] of file.lines())
        {
            // if line is a ini section store to section variable
            if(string.sub(line, 0, 1) == "[" && string.sub(line, -1) == "]")
            {
                section = line.replace("[", "").replace("]", "");
            }
            else if(string.sub(line, 0, 1) != "#" && line != "")
            {
                
                let [key, value] = line.split("=");
                key = key.trimStart().trimEnd();
                value = value.trimStart().trimEnd();
                contents.push([section, key, value]);
          
            }            
        }
        file.close();
        //loop though contents and set config values
        for(let [section, key, value] of contents)
        {
            if(section == "worldserver")
            {
                key = tostring(key).replace("Transmogrification.", "");

                if(typeof result[key] == "number"){
                    result[key] = tonumber(value);
                }
                else {
                    result[key] = value;
                }                
            }
        }
        return result;
    }
    
    export class TransmogrificationConfig {
        public Enable: number = 0;
        public UseCollectionSystem: number = 0;
        public AllowHiddenTransmog: number = 0;
        public TrackUnusableItems: number = 0;
        public RetroActiveAppearances: number = 0;
        public ResetRetroActiveAppearancesFlag: number = 0;
        public EnableTransmogInfo: number = 0;
        public TransmogNpcText: number = 0;
        public Allowed: string = "";
        public NotAllowed: string = "";
        public EnablePortable: number = 0;
        public ScaledCostModifier: number = 0;
        public CopperCost: number = 0;
        public RequireToken: number = 0;
        public TokenEntry: number = 0;
        public TokenAmount: number = 0;
        public AllowPoor: number = 0;
        public AllowCommon: number = 0;
        public AllowUncommon: number = 0;
        public AllowRare: number = 0;
        public AllowEpic: number = 0;
        public AllowLegendary: number = 0;
        public AllowArtifact: number = 0;
        public AllowHeirloom: number = 0;
        public AllowTradeable: number = 0;
        public AllowMixedArmorTypes: number = 0;
        public AllowMixedWeaponTypes: number = 0;
        public AllowMixedWeaponHandedness: number = 0;
        public AllowFishingPoles: number = 0;
        public IgnoreReqRace: number = 0;
        public IgnoreReqClass: number = 0;
        public IgnoreReqSkill: number = 0;
        public IgnoreReqSpell: number = 0;
        public IgnoreReqLevel: number = 0;
        public IgnoreReqEvent: number = 0;
        public IgnoreReqStats: number = 0;
        public EnableSets: number = 0;
        public MaxSets: number = 0;
        public EnableSetInfo: number = 0;
        public SetNpcText: number = 0;
        public SetCostModifier: number = 0;
        public SetCopperCost: number = 0;
    
        constructor() {
            // Initialize default values
            this.Enable = 1;
            this.UseCollectionSystem = 1;
            this.AllowHiddenTransmog = 1;
            // ... Initialize other properties with their default values
        }
        // You can add methods to load from a file, validate, etc.
    }
    
}