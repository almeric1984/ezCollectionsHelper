local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__New = ____lualib.__TS__New
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys
local ____exports = {}
local ____common = require("ezCollectionsHelper.utls.common")
local Common = ____common.Common
____exports.Data = __TS__Class()
local Data = ____exports.Data
Data.name = "Data"
function Data.prototype.____constructor(self)
    self.skinCollectionCache = {}
    self.transmogQuery = "SELECT custom_transmogrification.GUID, FakeEntry, item_instance.itemEntry FROM custom_transmogrification\n\tINNER JOIN item_instance ON custom_transmogrification.GUID = item_instance.guid\n\tWHERE `owner` = %d"
    self.accountQuery = "SELECT item_template_id FROM custom_unlocked_appearances WHERE account_id = %d"
    self.itemsQuery = "SELECT entry, InventoryType, Material, AllowableClass, AllowableRace, name, VerifiedBuild, Quality, SellPrice\n        FROM item_template where InventoryType > 0 AND InventoryType < 20 AND entry <> 5106 AND \n        FlagsExtra <> 8192 AND\n        FlagsExtra <> 6299648 AND\n        LOWER(name) NOT LIKE \"%%test %%\"; "
    self.ConfigQuery = "SELECT Prefix,Version, CacheVersion, ModulesConfPath FROM custom_ezCollectionsHelperConfig where RealmID = %d;"
    self.applyTransmogQuery = "INSERT INTO custom_transmogrification (GUID, FakeEntry, Owner) VALUES(%d, %d, %d) ON DUPLICATE KEY UPDATE FakeEntry = %d"
    self.removeTransmogQuery = "DELETE FROM custom_transmogrification where Owner = %d AND GUID = %d "
end
function Data.prototype.GetConfig(self)
    local queryString = string.format(
        self.ConfigQuery,
        GetRealmID()
    )
    local query = AuthDBQuery(queryString)
    repeat
        do
            Common.Settings.addonPrefix = query:GetString(0)
            Common.Settings.addonVersion = query:GetString(1)
            Common.Settings.addonCacheVersion = query:GetString(2)
            Common.Settings.ModulesConfPath = query:GetString(3)
        end
    until not query:NextRow()
end
function Data.prototype.ApplyTransmog(self, playerGuid, itemGuid, fakeEntry)
    CharDBQuery(string.format(
        self.applyTransmogQuery,
        itemGuid,
        fakeEntry,
        playerGuid,
        fakeEntry
    ))
    return true
end
function Data.prototype.DeleteTransmog(self, playerGuid, itemGuid)
    CharDBQuery(string.format(self.removeTransmogQuery, playerGuid, itemGuid))
    return true
end
function Data.prototype.CleanTransmogDb(self, playerGuid)
    __TS__ArrayForEach(
        self:GetCurrentTransmog(playerGuid),
        function(____, transmog)
            if transmog.FakeEntry == transmog.RealEntry then
                self:DeleteTransmog(playerGuid, transmog.GUID)
            end
        end
    )
    return true
end
function Data.prototype.GetSkinCollectionList(self)
    local result = {}
    local queryResult = WorldDBQuery(string.format(self.itemsQuery))
    if queryResult then
        repeat
            do
                local skinCollectionList = __TS__New(Common.SkinCollectionList)
                skinCollectionList.Id = queryResult:GetInt32(0)
                skinCollectionList.Slot = queryResult:GetInt32(1)
                skinCollectionList.Type = queryResult:GetInt32(2)
                skinCollectionList.ClassMask = queryResult:GetInt32(3)
                skinCollectionList.RaceMask = queryResult:GetInt32(4)
                skinCollectionList.Name = queryResult:GetString(5)
                skinCollectionList.VerifiedBuild = queryResult:GetInt32(6)
                skinCollectionList.Quality = queryResult:GetInt32(7)
                skinCollectionList.SellPrice = queryResult:GetInt32(8)
                if Common.Settings:AllowedQuality(skinCollectionList.Quality) then
                    if skinCollectionList.RaceMask == -1 then
                        skinCollectionList.RaceMask = 32767
                    end
                    result[skinCollectionList.Id] = skinCollectionList
                end
            end
        until not queryResult:NextRow()
    end
    self.skinCollectionCache = result
    return result
end
function Data.prototype.GetCurrentTransmog(self, playerGuid)
    if #__TS__ObjectKeys(self.skinCollectionCache) == 0 then
        return {}
    end
    local result = {}
    local queryResult = CharDBQuery(string.format(self.transmogQuery, playerGuid))
    if queryResult then
        repeat
            do
                local skinsOwned = __TS__New(Common.SkinsOwned)
                skinsOwned.GUID = queryResult:GetInt32(0)
                skinsOwned.FakeEntry = queryResult:GetInt32(1)
                skinsOwned.RealEntry = queryResult:GetInt32(2)
                skinsOwned.Slot = 0
                if self.skinCollectionCache[skinsOwned.RealEntry] ~= nil then
                    skinsOwned.Slot = self.skinCollectionCache[skinsOwned.RealEntry].Slot
                end
                result[#result + 1] = skinsOwned
            end
        until not queryResult:NextRow()
    end
    return result
end
function Data.prototype.GetAccountUnlockedAppearances(self, accountId)
    local result = {}
    local queryResult = CharDBQuery(string.format(self.accountQuery, accountId))
    if queryResult then
        repeat
            do
                result[#result + 1] = queryResult:GetInt32(0)
            end
        until not queryResult:NextRow()
    end
    return result
end
function Data.prototype.SearchAppearances(self, query, slot, accountId)
    local result = {}
    for ____, key in ipairs(__TS__ObjectKeys(self.skinCollectionCache)) do
        do
            local skinCollection = self.skinCollectionCache[key]
            if skinCollection.Slot ~= slot then
                goto __continue24
            end
            if #query == 0 or query == nil then
                result[#result + 1] = skinCollection.Id
            else
                if #query < 3 then
                    return result
                end
                if skinCollection.Slot == slot and skinCollection.Name:toLowerCase():includes(string.lower(query)) then
                    result[#result + 1] = skinCollection.Id
                end
            end
        end
        ::__continue24::
    end
    return result
end
function Data.prototype.PackSkinCollectionList(self, slot)
    local result = {}
    for ____, key in ipairs(__TS__ObjectKeys(self.skinCollectionCache)) do
        local skinCollection = self.skinCollectionCache[key]
        local data = tostring(skinCollection.Id)
        if skinCollection.Slot == Common:GetInventorySlotId(slot) then
            local classMask = ____exports.Data:IntToHexClass(skinCollection.ClassMask)
            local raceMask = ____exports.Data:IntToHexRace(skinCollection.RaceMask)
            data = (data .. "I") .. tostring(Common:GetInventorySlotId(slot))
            data = data .. "Q123"
            data = data .. "B15990"
            data = data .. "C5"
            data = (data .. "A") .. tostring(Common:MaterialToArmorType(skinCollection.Type))
            data = data .. "S0B"
            data = (data .. "L") .. classMask
            data = (data .. "R") .. raceMask
            result[#result + 1] = data
        end
    end
    return result
end
function Data.IntToHexClass(self, value)
    if value == 32767 or value == 262143 then
        value = -1
    end
    if value == 31240 then
        value = 8
    end
    local isNegative = value < 0
    if isNegative then
        value = value * -1
    end
    local hexstring = string.format("%X", value)
    if isNegative then
        hexstring = "-" .. hexstring
    end
    return hexstring
end
function Data.IntToHexRace(self, value)
    local flags = self:generateFlags(value)
    local newValue = self:convertFlagsToInt(flags)
    local isNegative = newValue < 0
    if isNegative then
        value = value * -1
    end
    local hexstring = string.format("%02X", newValue)
    if isNegative then
        hexstring = "-" .. hexstring
    end
    return hexstring
end
function Data.generateFlags(self, value)
    local flags = {}
    do
        local i = #Common.RaceData - 1
        while i >= 0 do
            local ____Common_RaceData_index_0 = Common.RaceData[i + 1]
            local id = ____Common_RaceData_index_0.id
            local name = ____Common_RaceData_index_0.name
            if value >= id then
                value = value - id
                flags[#flags + 1] = name
            end
            i = i - 1
        end
    end
    return flags
end
function Data.convertFlagsToInt(self, flags)
    local value = 0
    for ____, flagName in ipairs(flags) do
        for ____, data in ipairs(Common.RaceData) do
            local id = data.id
            local name = data.name
            if name == flagName then
                value = value + id
                break
            end
        end
    end
    return value
end
return ____exports
