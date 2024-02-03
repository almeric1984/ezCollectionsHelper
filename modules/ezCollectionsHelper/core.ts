import { Data } from "./utls/data";
import { Common } from "./utls/common";

declare function RunCommand(this: void, command : string ) : void;
class Core {
    public Data: Data;
    OnAddonMessage: addon_event_on_message = (
        event: number,
        sender: Player,
        type: number,
        prefix: string,
        message: string,
        target: number | Player | Guild | Group
    ) => {
        if (prefix == "ezCollections") {
            print(message)
            let messageHandler = new MessageHandler()
            let request = new Common.Request(message)
            if (request.command == "VERSION" && request.subCommand == Common.Settings.addonVersion) {
                messageHandler.Send(sender, `SERVERVERSION:${Common.Settings.addonVersion}:OK`, Common.Settings.addonPrefix)
                messageHandler.Send(sender, `CACHEVERSION:${Common.Settings.addonCacheVersion}`, Common.Settings.addonPrefix)
                messageHandler.Send(sender, "COLLECTIONS:SKIN:OWNEDITEM:END", Common.Settings.addonPrefix)
                messageHandler.Send(sender, "HIDEVISUALSLOTS:HEAD:SHOULDER:BACK:CHEST:TABARD:SHIRT:WRIST:HANDS:WAIST:LEGS:FEET:MAINHAND:OFFHAND:RANGED:MISC:ENCHANT", Common.Settings.addonPrefix)
            }
            else if (request.command == "LIST" && request.subCommand == "ALL") {
                this.BuildCameraDataList(request, messageHandler, sender);
                this.BuildCollectionList(request, messageHandler, sender);
            }
            else if (request.command == "LIST" && request.subCommand == "SKIN") {
                this.BuildOwnedSkinList(request, sender, messageHandler);
            }
            else if(request.command == "TRANSMOGRIFY" && request.subCommand == "OUTFIT") {
                let data = request.data as string[];
                if(data[0] == "COST")
                {
                    let outfitName = data[1];
                    let token = data[2];
                    data.splice(0, 3);
                    let price = 0;
                    for (let i = 0; i < data.length; i++) {
                        let [slot, newSkin]   = data[i].split("=")
                        if(tonumber(newSkin) == -1 || tonumber(newSkin) == 15)
                            continue;
                        let itemPrice = this.GetTransmogCost(newSkin);             
                        price += itemPrice;
                    }
                    messageHandler.Send(sender, `TRANSMOGRIFY:OUTFIT:COST:OK:${price}:0:${data.join(":")}`, Common.Settings.addonPrefix)
                }
                if(data[0] == "ADD")
                {
                    let outfitName = data[1];
                    let token = data[2];
                    data.splice(0, 3);
                    let price = 0;
                    let outfitString = "";
                    for (let i = 0; i < data.length; i++) {
                        let [slot, newSkin]   = data[i].split("=")
                        
                        if(tonumber(newSkin) == -1 || tonumber(newSkin) == 15)
                        {
                            outfitString += `${tonumber(slot) - 1} 1 `;
                            continue;
                        }
                        else
                            outfitString += `${tonumber(slot) - 1} ${newSkin} `;
                        let itemPrice = this.GetTransmogCost(newSkin); 
                        price += itemPrice;            
                    }
                    if(sender.GetCoinage() < price)
                    {
                        // Fails if player doesn't have enough gold
                        // This will just stop the transmog from happening will not throw an error
                        messageHandler.Send(sender, `TRANSMOGRIFY:OUTFIT:ADD:FAIL:${price}:0:0:0:Insufficient funds`, Common.Settings.addonPrefix)
                    }
                    else
                    {
                        sender.ModifyMoney(-price);
                        this.Data.AddOutfit(sender.GetGUIDLow(), outfitName, outfitString);
                        messageHandler.Send(sender, `TRANSMOGRIFY:OUTFIT:ADD:OK:${price}:0:${data.join(":")}`, Common.Settings.addonPrefix)
                        sender.ModifyMoney(-price);
                    }
                }
            }
            else if(request.command == "TRANSMOGRIFY" && request.subCommand == "COST") {
                let data = request.data as string[];
                let price = 0;
                for (let i = 1; i < data.length; i++) {
                    let [slotAndEntry, unk1, oldSkin, unk3, newSkin]   = data[i].split(",")
                    if(tonumber(newSkin) == -1 || tonumber(newSkin) == 15)
                        continue;
                    let itemPrice = this.GetTransmogCost(newSkin);             
                    price += itemPrice;
                }
                messageHandler.Send(sender, `TRANSMOGRIFY:COST:OK:${price}:0:${data.join(":")}`, Common.Settings.addonPrefix)
            }
            else if(request.command == "TRANSMOGRIFY" && request.subCommand == "APPLY") {
                let data = request.data as string[];
                let toDelete = []
                let price = 0;

                for (let i = 1; i < data.length; i++) {
                    let [slotAndEntry, unk1, oldSkin, unk3, newSkin]   = data[i].split(",")
                    if(tonumber(newSkin) != -1 && tonumber(newSkin) != 15)
                    {
                        let itemPrice = this.GetTransmogCost(newSkin);     
                        price += itemPrice;
                    }
                }
                
                if(sender.GetCoinage() < price)
                {
                    // Fails if player doesn't have enough gold
                    // This will just stop the transmog from happening will not throw an error
                    // TODO: slot=reason array
                    messageHandler.Send(sender, `TRANSMOGRIFY:APPLY:FAIL:0:0:${data.join(":")}`, Common.Settings.addonPrefix)
                    return;
                }

                for (let i = 1; i < data.length; i++) {
                    let [slotAndEntry, unk1, oldSkin, unk3, newSkin]   = data[i].split(",")
                    let fakeEntry = tonumber(newSkin)
                    let [slot, entry] = slotAndEntry.split("=")
                    let item = sender.GetEquippedItemBySlot(tonumber(slot) -1 );
                    
                    if(tonumber(fakeEntry) == -1)
                    {
                        this.Data.ApplyTransmog(sender.GetGUIDLow(), item.GetGUIDLow(), tonumber(entry))
                        toDelete.push(item.GetGUIDLow())
                    }
                    else if(tonumber(fakeEntry) == 15)
                    {
                        this.Data.ApplyTransmog(sender.GetGUIDLow(), item.GetGUIDLow(), 1)
                    }
                    else
                    {
                        this.Data.ApplyTransmog(sender.GetGUIDLow(), item.GetGUIDLow(), fakeEntry)
                    }
                    
                }

                sender.ModifyMoney(-price);
                messageHandler.Send(sender, `TRANSMOGRIFY:APPLY:OK:${price}:0:${data.join(":")}`, Common.Settings.addonPrefix)
                RunCommand(`transmog reload ${sender.GetName()}`);
                this.GetCurrentTransmog(request, sender, messageHandler);   
            }
            else if (request.command == "GETTRANSMOG" && request.subCommand == "ALL") {
                this.GetCurrentTransmog(request, sender, messageHandler);
            }
            else if (request.command == "TRANSMOGRIFY" && request.subCommand == "SEARCH") {
                this.DoSearchTransmog(request, sender, messageHandler);
            }
            // Not sure what this is doing exactly yet
            else if (request.command == "PRELOADCACHE") {
                messageHandler.Send(sender, `PRELOADCACHE:${request.subCommand}:0:0:`, Common.Settings.addonPrefix)
            }
        }
        return true;
    }
    OnLogin: player_event_on_login = (event: number, player: Player) => {
        this.Data.CleanTransmogDb(player.GetGUIDLow() );
    }

    OnLogout: player_event_on_logout = (event: number, player: Player) => {
        this.Data.CleanTransmogDb(player.GetGUIDLow() );
    }
    constructor() {
        this.Data = new Data();
        this.Data.GetConfig()
        this.Data.BuildCameraCache();
        Common.Settings.Config = Common.LoadConfig();
        print("Initializing EZCollectionsHelper")
        this.Data.GetSkinCollectionList();
        print("EZCollectionsHelper initialized")
    }

    private GetTransmogCost(newSkin: string) {
        let sellPrice = this.Data.skinCollectionCache[tonumber(newSkin)].SellPrice;
        let itemPrice = 0;
        // This is exactly like mod_transmog
        itemPrice = sellPrice < 10000 ? 10000 : sellPrice;
        itemPrice *= Common.Settings.Config.ScaledCostModifier;
        itemPrice += Common.Settings.Config.CopperCost;
        itemPrice = Math.floor(itemPrice);
        return itemPrice;
    }

    private GetCurrentTransmog(request: Common.Request, sender: Player, messageHandler: MessageHandler) {
        let slot = request.data as string;
        let responce = `GETTRANSMOG:ALL:`;
        let currentTransmog = this.Data.GetCurrentTransmog(sender.GetGUIDLow());
        for (let i = 0; i < currentTransmog.length; i++) {
            if(currentTransmog[i].Slot == 16)
                currentTransmog[i].Slot = 15;
            if(currentTransmog[i].FakeEntry == currentTransmog[i].RealEntry)
                responce += `${currentTransmog[i].Slot - 1}=${currentTransmog[i].RealEntry},0,0,0,1:`;
            else
                responce += `${currentTransmog[i].Slot - 1}=${currentTransmog[i].RealEntry},${currentTransmog[i].FakeEntry},0,0,1:`;
        }
        messageHandler.Send(sender, responce, Common.Settings.addonPrefix);
    }

    private DoSearchTransmog(request: Common.Request, sender: Player, messageHandler: MessageHandler) {
        let data = request.data as string[];
        let take = 0;
        let searchQuery = Common.DataToSearchQuery(data);
        let results = this.Data.SearchAppearances(searchQuery.query, searchQuery.slot, sender.GetAccountId());
        let responce = `TRANSMOGRIFY:SEARCH:${searchQuery.type}:${searchQuery.token}:RESULTS:`;
        messageHandler.Send(sender, `TRANSMOGRIFY:SEARCH:${searchQuery.type}:${searchQuery.token}:OK:${results.length }`, Common.Settings.addonPrefix);
        for (let i = 0; i < results.length; i++) {
            if (take > 30) {
                messageHandler.Send(sender, responce, Common.Settings.addonPrefix);
                responce = `TRANSMOGRIFY:SEARCH:${searchQuery.type}:${searchQuery.token}:RESULTS:`;
                take = 0;
            }
            responce += results[i] + ":";
            take++;
        }
        messageHandler.Send(sender, responce, Common.Settings.addonPrefix);
        messageHandler.Send(sender, `TRANSMOGRIFY:SEARCH:${searchQuery.type}:${searchQuery.token}:RESULTS:END`, Common.Settings.addonPrefix);
    }

    private BuildOwnedSkinList(request: Common.Request, sender: Player, messageHandler: MessageHandler) {
        let take = 0;
        let slot = request.data as string;
        let responce = `LIST:SKIN:`;
        let slotItems = this.Data.GetAccountUnlockedAppearances(sender.GetAccountId());
        for (let i = 0; i < slotItems.length; i++) {
            if (take == 10) {
                messageHandler.Send(sender, responce, Common.Settings.addonPrefix);
                responce = `LIST:SKIN:`;
                take = 0;
            }
            responce += slotItems[i] + ":";

            take++;
        }
        //send remaining items
        messageHandler.Send(sender, responce, Common.Settings.addonPrefix);
        messageHandler.Send(sender, `LIST:SKIN:END`, Common.Settings.addonPrefix);
    }

    private BuildCollectionList(request: Common.Request, messageHandler: MessageHandler, sender: Player) {
        let take = 0;
        let slot = request.data as string;
        let responce = `LIST:ALL:${slot}:`;
        let slotItems = this.Data.PackSkinCollectionList(slot,sender);
        // loop though PackSkinCollectionList and send 5 items at a time
        for (let i = 0; i < slotItems.length; i++) {
            if (take == 10) {
                messageHandler.Send(sender, responce, Common.Settings.addonPrefix);
                responce = `LIST:ALL:${slot}:`;
                take = 0;
            }
            responce += slotItems[i] + ":";

            take++;
        }
        //send remaining items
        messageHandler.Send(sender, responce, Common.Settings.addonPrefix);
        messageHandler.Send(sender, `LIST:ALL:${slot}:END`, Common.Settings.addonPrefix);
    }
    private BuildCameraDataList(request: Common.Request, messageHandler: MessageHandler, sender: Player) {
        let take = 0;
        let slot = request.data as string;
        let cameras = this.Data.GetCameraList();
        let responce = `LIST:DATA:CAMERAS:`;
        // loop though PackSkinCollectionList and send 5 items at a time
        for (let i = 0; i < cameras.length; i++) {
            let c = cameras[i];
            if (take == 10) {
                messageHandler.Send(sender, responce, Common.Settings.addonPrefix);
                responce = `LIST:DATA:CAMERAS:`;
                take = 0;
            }
            responce += `${c.Option},${c.Race},${c.Sex},${(c.Class * 100) + c.SubClass}=${c.X},${c.Y},${c.Z},${c.F},${c.Anim},${c.Name}:`;

            take++;
        }
        //send remaining items
        messageHandler.Send(sender, responce, Common.Settings.addonPrefix);
        messageHandler.Send(sender, `LIST:DATA:CAMERAS:END`, Common.Settings.addonPrefix);
    }
}

const core = new Core();
RegisterPlayerEvent(PlayerEvents.PLAYER_EVENT_ON_LOGIN, (...args) => core.OnLogin(...args));
RegisterPlayerEvent(PlayerEvents.PLAYER_EVENT_ON_LOGOUT, (...args) => core.OnLogout(...args));
RegisterServerEvent(ServerEvents.ADDON_EVENT_ON_MESSAGE, (...args) => core.OnAddonMessage(...args));
