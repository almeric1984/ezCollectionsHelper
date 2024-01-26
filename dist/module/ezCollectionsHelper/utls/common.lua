local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local ____exports = {}
____exports.Common = {}
local Common = ____exports.Common
do
    Common.Settings = __TS__Class()
    local Settings = Common.Settings
    Settings.name = "Settings"
    function Settings.prototype.____constructor(self)
    end
    Settings.addonPrefix = "ezCollections"
    Settings.addonVersion = "2.4.4"
    Settings.addonCacheVersion = "nocache"
    Settings.MinQuality = 0
    Settings.MaxQuality = 7
    Common.SearchQuery = __TS__Class()
    local SearchQuery = Common.SearchQuery
    SearchQuery.name = "SearchQuery"
    function SearchQuery.prototype.____constructor(self)
    end
    function Common.DataToSearchQuery(self, data)
        local query = __TS__New(Common.SearchQuery)
        query.type = tonumber(data[1])
        query.token = tonumber(data[2])
        query.slot = data[3]
        query.query = data[4]
        local subquery = __TS__StringSplit(data[5], ",")
        query.slotIndex = tonumber(subquery[1])
        query.entry = tonumber(subquery[2])
        query.unknown = tonumber(subquery[3])
        return query
    end
    Common.RaceData = {
        {id = 1, name = "Human"},
        {id = 2, name = "Orc"},
        {id = 4, name = "Dwarf"},
        {id = 8, name = "Night Elf"},
        {id = 16, name = "Undead"},
        {id = 32, name = "Tauren"},
        {id = 64, name = "Gnome"},
        {id = 128, name = "Troll"},
        {id = 512, name = "Blood Elf"},
        {id = 1024, name = "Draenei"}
    }
    Common.InventorySlots = InventorySlots or ({})
    Common.InventorySlots.HEAD = 1
    Common.InventorySlots[Common.InventorySlots.HEAD] = "HEAD"
    Common.InventorySlots.NECK = 2
    Common.InventorySlots[Common.InventorySlots.NECK] = "NECK"
    Common.InventorySlots.SHOULDER = 3
    Common.InventorySlots[Common.InventorySlots.SHOULDER] = "SHOULDER"
    Common.InventorySlots.SHIRT = 4
    Common.InventorySlots[Common.InventorySlots.SHIRT] = "SHIRT"
    Common.InventorySlots.CHEST = 5
    Common.InventorySlots[Common.InventorySlots.CHEST] = "CHEST"
    Common.InventorySlots.WAIST = 6
    Common.InventorySlots[Common.InventorySlots.WAIST] = "WAIST"
    Common.InventorySlots.LEGS = 7
    Common.InventorySlots[Common.InventorySlots.LEGS] = "LEGS"
    Common.InventorySlots.FEET = 8
    Common.InventorySlots[Common.InventorySlots.FEET] = "FEET"
    Common.InventorySlots.WRIST = 9
    Common.InventorySlots[Common.InventorySlots.WRIST] = "WRIST"
    Common.InventorySlots.HANDS = 10
    Common.InventorySlots[Common.InventorySlots.HANDS] = "HANDS"
    Common.InventorySlots.FINGER = 11
    Common.InventorySlots[Common.InventorySlots.FINGER] = "FINGER"
    Common.InventorySlots.TRINKET = 12
    Common.InventorySlots[Common.InventorySlots.TRINKET] = "TRINKET"
    Common.InventorySlots.ONEHAND = 13
    Common.InventorySlots[Common.InventorySlots.ONEHAND] = "ONEHAND"
    Common.InventorySlots.SHIELD = 14
    Common.InventorySlots[Common.InventorySlots.SHIELD] = "SHIELD"
    Common.InventorySlots.RANGE = 15
    Common.InventorySlots[Common.InventorySlots.RANGE] = "RANGE"
    Common.InventorySlots.BACK = 16
    Common.InventorySlots[Common.InventorySlots.BACK] = "BACK"
    Common.InventorySlots.TWOHAND = 17
    Common.InventorySlots[Common.InventorySlots.TWOHAND] = "TWOHAND"
    Common.InventorySlots.BAG = 18
    Common.InventorySlots[Common.InventorySlots.BAG] = "BAG"
    Common.InventorySlots.TABARD = 19
    Common.InventorySlots[Common.InventorySlots.TABARD] = "TABARD"
    function Common.GetInventorySlotId(self, slotName)
        return Common.InventorySlots[string.upper(slotName)]
    end
    function Common.GetInventorySlotName(self, slotId)
        return Common.InventorySlots[slotId]
    end
    function Common.MaterialToArmorType(self, material)
        repeat
            local ____switch9 = material
            local ____cond9 = ____switch9 == 7
            if ____cond9 then
                return 1
            end
            ____cond9 = ____cond9 or ____switch9 == 6
            if ____cond9 then
                return 4
            end
            ____cond9 = ____cond9 or ____switch9 == 5
            if ____cond9 then
                return 3
            end
            do
                return 2
            end
        until true
    end
    Common.Request = __TS__Class()
    local Request = Common.Request
    Request.name = "Request"
    function Request.prototype.____constructor(self, message)
        local ____TS__StringSplit_result_0 = __TS__StringSplit(message, ":")
        local command = ____TS__StringSplit_result_0[1]
        local subCommand = ____TS__StringSplit_result_0[2]
        local data = __TS__ArraySlice(____TS__StringSplit_result_0, 2)
        self.command = command
        if subCommand then
            self.subCommand = subCommand
        end
        if data then
            if #data == 1 then
                self.data = data[1]
            else
                self.data = data
            end
        end
    end
    Common.SkinsOwned = __TS__Class()
    local SkinsOwned = Common.SkinsOwned
    SkinsOwned.name = "SkinsOwned"
    function SkinsOwned.prototype.____constructor(self)
    end
    Common.SkinCollectionList = __TS__Class()
    local SkinCollectionList = Common.SkinCollectionList
    SkinCollectionList.name = "SkinCollectionList"
    function SkinCollectionList.prototype.____constructor(self)
        self.Icon = ""
        self.Camra = ""
        self.SourceMask = 0
        self.RaceMask = 0
        self.ClassMask = 0
    end
end
return ____exports
