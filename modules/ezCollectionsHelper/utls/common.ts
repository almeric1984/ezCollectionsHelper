export namespace Common {

    export class Settings {
        public static readonly addonPrefix = "ezCollections";
        public static readonly addonVersion = "2.4.4";
        public static readonly addonCacheVersion = "nocache";
        public static readonly MinQuality = 0;
        public static readonly MaxQuality = 7;
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

    export function DataToSearchQuery(data : string[]) : SearchQuery {
        let query = new SearchQuery()
        query.type = tonumber(data[0])
        query.token = tonumber(data[1])
        query.slot = data[2]
        query.query = data[3]
        let subquery = data[4].split(",")
        query.slotIndex = tonumber(subquery[0])
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
        TWOHAND     = 17,
        BAG         = 18,
        TABARD      = 19,
    }

    export function GetInventorySlotId(slotName: string) : number {
        return InventorySlots[slotName.toUpperCase()]
    }

    export function GetInventorySlotName(slotId: number) : string {
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
    }

}