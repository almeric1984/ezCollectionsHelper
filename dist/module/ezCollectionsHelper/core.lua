local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local __TS__StringSplit = ____lualib.__TS__StringSplit
local ____exports = {}
local ____data = require("ezCollectionsHelper.utls.data")
local Data = ____data.Data
local ____common = require("ezCollectionsHelper.utls.common")
local Common = ____common.Common
local Core = __TS__Class()
Core.name = "Core"
function Core.prototype.____constructor(self)
    self.OnAddonMessage = function(____, event, sender, ____type, prefix, message, target)
        if prefix == "ezCollections" then
            local messageHandler = __TS__New(MessageHandler)
            local request = __TS__New(Common.Request, message)
            if request.command == "VERSION" and request.subCommand == Common.Settings.addonVersion then
                messageHandler:Send(sender, ("SERVERVERSION:" .. Common.Settings.addonVersion) .. ":OK", Common.Settings.addonPrefix)
                messageHandler:Send(sender, "CACHEVERSION:" .. Common.Settings.addonCacheVersion, Common.Settings.addonPrefix)
                messageHandler:Send(sender, "COLLECTIONS:SKIN:OWNEDITEM:END", Common.Settings.addonPrefix)
                messageHandler:Send(sender, "HIDEVISUALSLOTS:HEAD:SHOULDER:BACK:CHEST:TABARD:SHIRT:WRIST:HANDS:WAIST:LEGS:FEET:MAINHAND:OFFHAND:RANGED:MISC:ENCHANT", Common.Settings.addonPrefix)
                messageHandler:Send(sender, "OUTFITPARAMS:10:0:0:0", Common.Settings.addonPrefix)
            elseif request.command == "LIST" and request.subCommand == "ALL" then
                self:BuildCameraDataList(request, messageHandler, sender)
                self:BuildCollectionList(request, messageHandler, sender)
            elseif request.command == "LIST" and request.subCommand == "SKIN" then
                self:BuildOwnedSkinList(request, sender, messageHandler)
                local outfits = self.Data:GetOutfits(sender:GetGUIDLow())
                do
                    local i = 0
                    while i < #outfits do
                        local outfit = outfits[i + 1]
                        local outfitString = Common:OutfitDatabaseStringToOutfitString(outfit.Data)
                        messageHandler:Send(
                            sender,
                            (((("TRANSMOGRIFY:OUTFIT:ADD:" .. tostring(outfit.Id)) .. ":") .. outfit.Name) .. ":0:") .. outfitString,
                            Common.Settings.addonPrefix
                        )
                        i = i + 1
                    end
                end
            elseif request.command == "TRANSMOGRIFY" and request.subCommand == "OUTFIT" then
                local data = request.data
                if data[1] == "COST" then
                    local outfitName = data[2]
                    local token = data[3]
                    __TS__ArraySplice(data, 0, 3)
                    local price = 0
                    do
                        local i = 0
                        while i < #data do
                            do
                                local slot, newSkin = table.unpack(__TS__StringSplit(data[i + 1], "="))
                                if tonumber(newSkin) == -1 or tonumber(newSkin) == 15 then
                                    goto __continue11
                                end
                            end
                            ::__continue11::
                            i = i + 1
                        end
                    end
                    messageHandler:Send(
                        sender,
                        (("TRANSMOGRIFY:OUTFIT:COST:OK:" .. tostring(price)) .. ":0:") .. table.concat(data, ":"),
                        Common.Settings.addonPrefix
                    )
                end
                if data[1] == "EDITCOST" then
                    local outfitId = data[2]
                    local outfitName = data[3]
                    local token = data[4]
                    __TS__ArraySplice(data, 0, 4)
                    local price = 0
                    do
                        local i = 0
                        while i < #data do
                            do
                                local slot, newSkin = table.unpack(__TS__StringSplit(data[i + 1], "="))
                                if tonumber(newSkin) == -1 or tonumber(newSkin) == 15 then
                                    goto __continue14
                                end
                            end
                            ::__continue14::
                            i = i + 1
                        end
                    end
                    messageHandler:Send(
                        sender,
                        (((("TRANSMOGRIFY:OUTFIT:EDITCOST:OK:" .. outfitId) .. ":") .. tostring(price)) .. ":0:") .. table.concat(data, ":"),
                        Common.Settings.addonPrefix
                    )
                elseif data[1] == "EDIT" then
                    local outfitId = data[2]
                    local outfitName = data[3]
                    local token = data[4]
                    __TS__ArraySplice(data, 0, 4)
                    local price = 0
                    local outfitString = ""
                    do
                        local i = 0
                        while i < #data do
                            do
                                local slot, newSkin = table.unpack(__TS__StringSplit(data[i + 1], "="))
                                if tonumber(newSkin) == -1 or tonumber(newSkin) == 15 then
                                    outfitString = outfitString .. tostring(tonumber(slot) - 1) .. " 1 "
                                    goto __continue17
                                else
                                    outfitString = outfitString .. ((tostring(tonumber(slot) - 1) .. " ") .. newSkin) .. " "
                                end
                            end
                            ::__continue17::
                            i = i + 1
                        end
                    end
                    self.Data:UpdateOutfit(
                        sender:GetGUIDLow(),
                        tonumber(outfitId),
                        outfitName,
                        outfitString
                    )
                    outfitString = Common:OutfitDatabaseStringToOutfitString(outfitString)
                    messageHandler:Send(sender, (("TRANSMOGRIFY:OUTFIT:EDIT:OK:" .. outfitId) .. ":0:0:") .. outfitString, Common.Settings.addonPrefix)
                    local outfits = self.Data:GetOutfits(sender:GetGUIDLow())
                    do
                        local i = 0
                        while i < #outfits do
                            local outfit = outfits[i + 1]
                            if outfit.Id == tonumber(outfitId) then
                                local outfitString = Common:OutfitDatabaseStringToOutfitString(outfit.Data)
                                messageHandler:Send(
                                    sender,
                                    (((("TRANSMOGRIFY:OUTFIT:ADD:" .. tostring(outfit.Id)) .. ":") .. outfit.Name) .. ":0:") .. outfitString,
                                    Common.Settings.addonPrefix
                                )
                                break
                            end
                            i = i + 1
                        end
                    end
                elseif data[1] == "ADD" then
                    local outfitName = data[2]
                    local token = data[3]
                    __TS__ArraySplice(data, 0, 3)
                    local price = 0
                    local outfitString = ""
                    do
                        local i = 0
                        while i < #data do
                            do
                                local slot, newSkin = table.unpack(__TS__StringSplit(data[i + 1], "="))
                                if tonumber(newSkin) == -1 or tonumber(newSkin) == 15 then
                                    outfitString = outfitString .. tostring(tonumber(slot) - 1) .. " 1 "
                                    goto __continue23
                                else
                                    outfitString = outfitString .. ((tostring(tonumber(slot) - 1) .. " ") .. newSkin) .. " "
                                end
                            end
                            ::__continue23::
                            i = i + 1
                        end
                    end
                    local outfitIndex = self.Data:AddOutfit(
                        sender:GetGUIDLow(),
                        outfitName,
                        outfitString
                    )
                    messageHandler:Send(
                        sender,
                        (("TRANSMOGRIFY:OUTFIT:ADD:OK:" .. tostring(price)) .. ":0:") .. table.concat(data, ":"),
                        Common.Settings.addonPrefix
                    )
                    outfitString = Common:OutfitDatabaseStringToOutfitString(outfitString)
                    messageHandler:Send(
                        sender,
                        (((("TRANSMOGRIFY:OUTFIT:ADD:" .. tostring(outfitIndex)) .. ":") .. outfitName) .. ":0:") .. outfitString,
                        Common.Settings.addonPrefix
                    )
                elseif data[1] == "REMOVE" then
                    local outfitId = tonumber(data[2])
                    self.Data:DeleteOutfit(
                        sender:GetGUIDLow(),
                        outfitId
                    )
                    messageHandler:Send(sender, "TRANSMOGRIFY:OUTFIT:REMOVE:OK", Common.Settings.addonPrefix)
                    messageHandler:Send(
                        sender,
                        ("TRANSMOGRIFY:OUTFIT:REMOVE:" .. tostring(outfitId)) .. ":",
                        Common.Settings.addonPrefix
                    )
                elseif data[1] == "RENAME" then
                    local outfitId = tonumber(data[2])
                    local newName = data[3]
                    self.Data:RenameOutfit(
                        sender:GetGUIDLow(),
                        outfitId,
                        newName
                    )
                    local outfits = self.Data:GetOutfits(sender:GetGUIDLow())
                    messageHandler:Send(sender, "TRANSMOGRIFY:OUTFIT:RENAME:OK", Common.Settings.addonPrefix)
                    do
                        local i = 0
                        while i < #outfits do
                            local outfit = outfits[i + 1]
                            if outfits[i + 1].Id == outfitId then
                                local outfitString = Common:OutfitDatabaseStringToOutfitString(outfit.Data)
                                messageHandler:Send(
                                    sender,
                                    (((("TRANSMOGRIFY:OUTFIT:ADD:" .. tostring(outfit.Id)) .. ":") .. outfit.Name) .. ":0:") .. outfitString,
                                    Common.Settings.addonPrefix
                                )
                                break
                            end
                            i = i + 1
                        end
                    end
                end
            elseif request.command == "TRANSMOGRIFY" and request.subCommand == "COST" then
                local data = request.data
                local price = 0
                do
                    local i = 1
                    while i < #data do
                        do
                            local slotAndEntry, unk1, oldSkin, unk3, newSkin = table.unpack(__TS__StringSplit(data[i + 1], ","))
                            if tonumber(newSkin) == -1 or tonumber(newSkin) == 15 then
                                goto __continue31
                            end
                            local itemPrice = self:GetTransmogCost(newSkin)
                            price = price + itemPrice
                        end
                        ::__continue31::
                        i = i + 1
                    end
                end
                messageHandler:Send(
                    sender,
                    (("TRANSMOGRIFY:COST:OK:" .. tostring(price)) .. ":0:") .. table.concat(data, ":"),
                    Common.Settings.addonPrefix
                )
            elseif request.command == "TRANSMOGRIFY" and request.subCommand == "APPLY" then
                local data = request.data
                local toDelete = {}
                local price = 0
                do
                    local i = 1
                    while i < #data do
                        local slotAndEntry, unk1, oldSkin, unk3, newSkin = table.unpack(__TS__StringSplit(data[i + 1], ","))
                        if tonumber(newSkin) ~= -1 and tonumber(newSkin) ~= 15 then
                            local itemPrice = self:GetTransmogCost(newSkin)
                            price = price + itemPrice
                        end
                        i = i + 1
                    end
                end
                if sender:GetCoinage() < price then
                    messageHandler:Send(
                        sender,
                        "TRANSMOGRIFY:APPLY:FAIL:0:0:" .. table.concat(data, ":"),
                        Common.Settings.addonPrefix
                    )
                    return
                end
                do
                    local i = 1
                    while i < #data do
                        local slotAndEntry, unk1, oldSkin, unk3, newSkin = table.unpack(__TS__StringSplit(data[i + 1], ","))
                        local fakeEntry = tonumber(newSkin)
                        local slot, entry = table.unpack(__TS__StringSplit(slotAndEntry, "="))
                        local item = sender:GetEquippedItemBySlot(tonumber(slot) - 1)
                        if tonumber(fakeEntry) == -1 then
                            self.Data:ApplyTransmog(
                                sender:GetGUIDLow(),
                                item:GetGUIDLow(),
                                tonumber(entry)
                            )
                            toDelete[#toDelete + 1] = item:GetGUIDLow()
                        elseif tonumber(fakeEntry) == 15 then
                            self.Data:ApplyTransmog(
                                sender:GetGUIDLow(),
                                item:GetGUIDLow(),
                                1
                            )
                        else
                            self.Data:ApplyTransmog(
                                sender:GetGUIDLow(),
                                item:GetGUIDLow(),
                                fakeEntry
                            )
                        end
                        i = i + 1
                    end
                end
                sender:ModifyMoney(-price)
                messageHandler:Send(
                    sender,
                    (("TRANSMOGRIFY:APPLY:OK:" .. tostring(price)) .. ":0:") .. table.concat(data, ":"),
                    Common.Settings.addonPrefix
                )
                RunCommand("transmog reload " .. sender:GetName())
                self:GetCurrentTransmog(request, sender, messageHandler)
            elseif request.command == "GETTRANSMOG" and request.subCommand == "ALL" then
                self:GetCurrentTransmog(request, sender, messageHandler)
            elseif request.command == "TRANSMOGRIFY" and request.subCommand == "SEARCH" then
                self:DoSearchTransmog(request, sender, messageHandler)
            elseif request.command == "PRELOADCACHE" then
                messageHandler:Send(sender, ("PRELOADCACHE:" .. request.subCommand) .. ":0:0:", Common.Settings.addonPrefix)
            end
        end
        return true
    end
    self.OnLogin = function(____, event, player)
        self.Data:CleanTransmogDb(player:GetGUIDLow())
    end
    self.OnLogout = function(____, event, player)
        self.Data:CleanTransmogDb(player:GetGUIDLow())
    end
    self.Data = __TS__New(Data)
    self.Data:GetConfig()
    self.Data:BuildCameraCache()
    Common.Settings.Config = Common:LoadConfig()
    print("Initializing EZCollectionsHelper")
    self.Data:GetSkinCollectionList()
    print("EZCollectionsHelper initialized")
end
function Core.prototype.GetTransmogCost(self, newSkin)
    local sellPrice = self.Data.skinCollectionCache[tonumber(newSkin)].SellPrice
    local itemPrice = 0
    itemPrice = sellPrice < 10000 and 10000 or sellPrice
    itemPrice = itemPrice * Common.Settings.Config.ScaledCostModifier
    itemPrice = itemPrice + Common.Settings.Config.CopperCost
    itemPrice = math.floor(itemPrice)
    return itemPrice
end
function Core.prototype.GetCurrentTransmog(self, request, sender, messageHandler)
    local slot = request.data
    local responce = "GETTRANSMOG:ALL:"
    local currentTransmog = self.Data:GetCurrentTransmog(sender:GetGUIDLow())
    do
        local i = 0
        while i < #currentTransmog do
            if currentTransmog[i + 1].Slot == 16 then
                currentTransmog[i + 1].Slot = 15
            end
            if currentTransmog[i + 1].FakeEntry == currentTransmog[i + 1].RealEntry then
                responce = responce .. ((tostring(currentTransmog[i + 1].Slot - 1) .. "=") .. tostring(currentTransmog[i + 1].RealEntry)) .. ",0,0,0,1:"
            else
                responce = responce .. ((((tostring(currentTransmog[i + 1].Slot - 1) .. "=") .. tostring(currentTransmog[i + 1].RealEntry)) .. ",") .. tostring(currentTransmog[i + 1].FakeEntry)) .. ",0,0,1:"
            end
            i = i + 1
        end
    end
    messageHandler:Send(sender, responce, Common.Settings.addonPrefix)
end
function Core.prototype.DoSearchTransmog(self, request, sender, messageHandler)
    local data = request.data
    local take = 0
    local searchQuery = Common:DataToSearchQuery(data)
    local results = self.Data:SearchAppearances(
        searchQuery.query,
        searchQuery.slot,
        sender:GetAccountId()
    )
    local responce = ((("TRANSMOGRIFY:SEARCH:" .. tostring(searchQuery.type)) .. ":") .. tostring(searchQuery.token)) .. ":RESULTS:"
    messageHandler:Send(
        sender,
        (((("TRANSMOGRIFY:SEARCH:" .. tostring(searchQuery.type)) .. ":") .. tostring(searchQuery.token)) .. ":OK:") .. tostring(#results),
        Common.Settings.addonPrefix
    )
    do
        local i = 0
        while i < #results do
            if take > 30 then
                messageHandler:Send(sender, responce, Common.Settings.addonPrefix)
                responce = ((("TRANSMOGRIFY:SEARCH:" .. tostring(searchQuery.type)) .. ":") .. tostring(searchQuery.token)) .. ":RESULTS:"
                take = 0
            end
            responce = responce .. tostring(results[i + 1]) .. ":"
            take = take + 1
            i = i + 1
        end
    end
    messageHandler:Send(sender, responce, Common.Settings.addonPrefix)
    messageHandler:Send(
        sender,
        ((("TRANSMOGRIFY:SEARCH:" .. tostring(searchQuery.type)) .. ":") .. tostring(searchQuery.token)) .. ":RESULTS:END",
        Common.Settings.addonPrefix
    )
end
function Core.prototype.BuildOwnedSkinList(self, request, sender, messageHandler)
    local take = 0
    local slot = request.data
    local responce = "LIST:SKIN:"
    local slotItems = self.Data:GetAccountUnlockedAppearances(sender:GetAccountId())
    do
        local i = 0
        while i < #slotItems do
            if take == 10 then
                messageHandler:Send(sender, responce, Common.Settings.addonPrefix)
                responce = "LIST:SKIN:"
                take = 0
            end
            responce = responce .. tostring(slotItems[i + 1]) .. ":"
            take = take + 1
            i = i + 1
        end
    end
    messageHandler:Send(sender, responce, Common.Settings.addonPrefix)
    messageHandler:Send(sender, "LIST:SKIN:END", Common.Settings.addonPrefix)
end
function Core.prototype.BuildCollectionList(self, request, messageHandler, sender)
    local take = 0
    local slot = request.data
    local responce = ("LIST:ALL:" .. slot) .. ":"
    local slotItems = self.Data:PackSkinCollectionList(slot, sender)
    do
        local i = 0
        while i < #slotItems do
            if take == 10 then
                messageHandler:Send(sender, responce, Common.Settings.addonPrefix)
                responce = ("LIST:ALL:" .. slot) .. ":"
                take = 0
            end
            responce = responce .. slotItems[i + 1] .. ":"
            take = take + 1
            i = i + 1
        end
    end
    messageHandler:Send(sender, responce, Common.Settings.addonPrefix)
    messageHandler:Send(sender, ("LIST:ALL:" .. slot) .. ":END", Common.Settings.addonPrefix)
end
function Core.prototype.BuildCameraDataList(self, request, messageHandler, sender)
    local take = 0
    local slot = request.data
    local cameras = self.Data:GetCameraList()
    local responce = "LIST:DATA:CAMERAS:"
    do
        local i = 0
        while i < #cameras do
            local c = cameras[i + 1]
            if take == 10 then
                messageHandler:Send(sender, responce, Common.Settings.addonPrefix)
                responce = "LIST:DATA:CAMERAS:"
                take = 0
            end
            responce = responce .. ((((((((((((((((((tostring(c.Option) .. ",") .. tostring(c.Race)) .. ",") .. tostring(c.Sex)) .. ",") .. tostring(c.Class * 100 + c.SubClass)) .. "=") .. tostring(c.X)) .. ",") .. tostring(c.Y)) .. ",") .. tostring(c.Z)) .. ",") .. tostring(c.F)) .. ",") .. tostring(c.Anim)) .. ",") .. c.Name) .. ":"
            take = take + 1
            i = i + 1
        end
    end
    messageHandler:Send(sender, responce, Common.Settings.addonPrefix)
    messageHandler:Send(sender, "LIST:DATA:CAMERAS:END", Common.Settings.addonPrefix)
end
local core = __TS__New(Core)
RegisterPlayerEvent(
    3,
    function(...) return core:OnLogin(...) end
)
RegisterPlayerEvent(
    4,
    function(...) return core:OnLogout(...) end
)
RegisterServerEvent(
    30,
    function(...) return core:OnAddonMessage(...) end
)
return ____exports
