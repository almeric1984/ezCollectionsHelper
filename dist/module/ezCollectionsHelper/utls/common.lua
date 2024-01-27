local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local __TS__StringReplace = ____lualib.__TS__StringReplace
local __TS__StringTrimStart = ____lualib.__TS__StringTrimStart
local __TS__StringTrimEnd = ____lualib.__TS__StringTrimEnd
local ____exports = {}
____exports.Common = {}
local Common = ____exports.Common
do
    Common.Settings = __TS__Class()
    local Settings = Common.Settings
    Settings.name = "Settings"
    function Settings.prototype.____constructor(self)
    end
    function Settings.AllowedQuality(self, quality)
        if quality == Common.Quality.Poor and self.Config.AllowPoor == 1 then
            return true
        end
        if quality == Common.Quality.Common and self.Config.AllowCommon == 1 then
            return true
        end
        if quality == Common.Quality.Uncommon and self.Config.AllowUncommon == 1 then
            return true
        end
        if quality == Common.Quality.Rare and self.Config.AllowRare == 1 then
            return true
        end
        if quality == Common.Quality.Epic and self.Config.AllowEpic == 1 then
            return true
        end
        if quality == Common.Quality.Legendary and self.Config.AllowLegendary == 1 then
            return true
        end
        if quality == Common.Quality.Artifact and self.Config.AllowArtifact == 1 then
            return true
        end
        if quality == Common.Quality.Heirloom and self.Config.AllowHeirloom == 1 then
            return true
        end
        return false
    end
    Settings.addonPrefix = "ezCollections"
    Settings.addonVersion = "2.4.4"
    Settings.addonCacheVersion = "nocache"
    Settings.ModulesConfPath = "etc/modules"
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
    Common.Quality = Quality or ({})
    Common.Quality.Poor = 0
    Common.Quality[Common.Quality.Poor] = "Poor"
    Common.Quality.Common = 1
    Common.Quality[Common.Quality.Common] = "Common"
    Common.Quality.Uncommon = 2
    Common.Quality[Common.Quality.Uncommon] = "Uncommon"
    Common.Quality.Rare = 3
    Common.Quality[Common.Quality.Rare] = "Rare"
    Common.Quality.Epic = 4
    Common.Quality[Common.Quality.Epic] = "Epic"
    Common.Quality.Legendary = 5
    Common.Quality[Common.Quality.Legendary] = "Legendary"
    Common.Quality.Artifact = 6
    Common.Quality[Common.Quality.Artifact] = "Artifact"
    Common.Quality.Heirloom = 7
    Common.Quality[Common.Quality.Heirloom] = "Heirloom"
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
            local ____switch18 = material
            local ____cond18 = ____switch18 == 7
            if ____cond18 then
                return 1
            end
            ____cond18 = ____cond18 or ____switch18 == 6
            if ____cond18 then
                return 4
            end
            ____cond18 = ____cond18 or ____switch18 == 5
            if ____cond18 then
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
    function Common.LoadConfig(self)
        local result = __TS__New(Common.TransmogrificationConfig)
        local file = io.open(____exports.Common.Settings.ModulesConfPath .. "/transmog.conf", "r")
        local contents = {}
        if file == nil then
            file = io.open(____exports.Common.Settings.ModulesConfPath .. "/transmog.conf.dist", "r")
            if file == nil then
                print("Error: Could not load config file")
                return
            end
        end
        local section = ""
        for line in file:lines() do
            if string.sub(line, 0, 1) == "[" and string.sub(line, -1) == "]" then
                section = __TS__StringReplace(
                    __TS__StringReplace(line, "[", ""),
                    "]",
                    ""
                )
            elseif string.sub(line, 0, 1) ~= "#" and line ~= "" then
                local key, value = table.unpack(__TS__StringSplit(line, "="))
                key = __TS__StringTrimEnd(__TS__StringTrimStart(key))
                value = __TS__StringTrimEnd(__TS__StringTrimStart(value))
                contents[#contents + 1] = {section, key, value}
            end
        end
        file:close()
        print("Loading config")
        for ____, ____value in ipairs(contents) do
            local section = ____value[1]
            local key = ____value[2]
            local value = ____value[3]
            if section == "worldserver" then
                key = __TS__StringReplace(
                    tostring(key),
                    "Transmogrification.",
                    ""
                )
                if type(result[key]) == "number" then
                    result[key] = tonumber(value)
                else
                    result[key] = value
                end
            end
        end
        return result
    end
    Common.TransmogrificationConfig = __TS__Class()
    local TransmogrificationConfig = Common.TransmogrificationConfig
    TransmogrificationConfig.name = "TransmogrificationConfig"
    function TransmogrificationConfig.prototype.____constructor(self)
        self.Enable = 0
        self.UseCollectionSystem = 0
        self.AllowHiddenTransmog = 0
        self.TrackUnusableItems = 0
        self.RetroActiveAppearances = 0
        self.ResetRetroActiveAppearancesFlag = 0
        self.EnableTransmogInfo = 0
        self.TransmogNpcText = 0
        self.Allowed = ""
        self.NotAllowed = ""
        self.EnablePortable = 0
        self.ScaledCostModifier = 0
        self.CopperCost = 0
        self.RequireToken = 0
        self.TokenEntry = 0
        self.TokenAmount = 0
        self.AllowPoor = 0
        self.AllowCommon = 0
        self.AllowUncommon = 0
        self.AllowRare = 0
        self.AllowEpic = 0
        self.AllowLegendary = 0
        self.AllowArtifact = 0
        self.AllowHeirloom = 0
        self.AllowTradeable = 0
        self.AllowMixedArmorTypes = 0
        self.AllowMixedWeaponTypes = 0
        self.AllowMixedWeaponHandedness = 0
        self.AllowFishingPoles = 0
        self.IgnoreReqRace = 0
        self.IgnoreReqClass = 0
        self.IgnoreReqSkill = 0
        self.IgnoreReqSpell = 0
        self.IgnoreReqLevel = 0
        self.IgnoreReqEvent = 0
        self.IgnoreReqStats = 0
        self.EnableSets = 0
        self.MaxSets = 0
        self.EnableSetInfo = 0
        self.SetNpcText = 0
        self.SetCostModifier = 0
        self.SetCopperCost = 0
        self.Enable = 1
        self.UseCollectionSystem = 1
        self.AllowHiddenTransmog = 1
    end
end
return ____exports
