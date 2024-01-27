local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
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
            elseif request.command == "LIST" and request.subCommand == "ALL" then
                self:BuildCollectionList(request, messageHandler, sender)
            elseif request.command == "LIST" and request.subCommand == "SKIN" then
                self:BuildOwnedSkinList(request, sender, messageHandler)
            elseif request.command == "TRANSMOGRIFY" and request.subCommand == "COST" then
                local data = request.data
                local price = 0
                do
                    local i = 1
                    while i < #data do
                        do
                            local slotAndEntry, unk1, oldSkin, unk3, newSkin = table.unpack(__TS__StringSplit(data[i + 1], ","))
                            if tonumber(newSkin) == -1 then
                                goto __continue9
                            end
                            local itemPrice = self:GetTransmogCost(newSkin)
                            price = price + itemPrice
                        end
                        ::__continue9::
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
                        if tonumber(newSkin) ~= -1 then
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
        searchQuery.slotIndex,
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
    local slotItems = self.Data:PackSkinCollectionList(slot)
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
