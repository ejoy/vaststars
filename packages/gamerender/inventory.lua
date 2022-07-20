local create_cache = require "utility.multiple_cache"
local iworld = require "gameplay.interface.world"
local ichest = require "gameplay.interface.chest"
local iprototype = require "gameplay.interface.prototype"

local gameplay_core = require "gameplay.core"
local CACHE_NAMES <const> = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local TEMPORARY_CACHE_NAMES <const> = {"TEMPORARY"}
local CONSTRUCTED_CACHE_NAMES <const> = {"CONSTRUCTED"}
local _VASTSTARS_DEBUG_INFINITE_ITEM <const> = require("debugger").infinite_item()

local function flush(self)
    self._inventory:clear(CACHE_NAMES)
    local e = iworld:get_headquater_entity(gameplay_core.get_world())
    if not e then
        return
    end

    for prototype, count in pairs(ichest:item_counts(gameplay_core.get_world(), e)) do
        local t = self._inventory:get(CONSTRUCTED_CACHE_NAMES, prototype)
        if t then -- different slot may have same prototype
            t.count = t.count + count
        else
            self._inventory:set("CONSTRUCTED", {
                prototype = prototype,
                count = count,
            })
        end
    end
end

local function get(self, prototype)
    if _VASTSTARS_DEBUG_INFINITE_ITEM then
        return {
            prototype = prototype,
            count = 999,
        }
    end

    local v = self._inventory:get(CACHE_NAMES, prototype)
    if not v then
        return {
            prototype = prototype,
            count = 0,
        }
    end
    return v
end

local function revert(self)
    self._inventory:clear(TEMPORARY_CACHE_NAMES)
end

local function confirm(self)
    self._inventory:commit("TEMPORARY", "CONFIRM")
end

local function complete(self)
    if _VASTSTARS_DEBUG_INFINITE_ITEM then
        return true
    end

    local gameplay_world = gameplay_core.get_world()
    local e = iworld:get_headquater_entity(gameplay_world)
    if not e then
        log.error("can not find headquater entity")
        return false
    end

    for _, item in self._inventory:all("CONFIRM") do
        local original = assert(self._inventory:get(CONSTRUCTED_CACHE_NAMES, item.prototype))
        assert(original.count >= item.count)
        local decrease = original.count - item.count
        if not gameplay_world:container_pickup(e.chest.container, item.prototype, decrease) then
            log.error("can not pickup item", iprototype.queryById(item.prototype).name, decrease)
            return false
        end
    end
    return true
end

local function decrease(self, prototype, count)
    if _VASTSTARS_DEBUG_INFINITE_ITEM then
        return true
    end

    local function clone(item) -- TODO: maybe have a better way to clone?
        local new = {}
        new.prototype = item.prototype
        new.count = item.count
        return new
    end

    local item = self._inventory:modify(CACHE_NAMES, prototype, clone)
    if not item then
        return false
    end

    if item.count < count then
        return false
    end

    item.count = item.count - count
    return true
end

local function modity(self, prototype)
    local function clone(item) -- TODO: maybe have a better way to clone?
        local new = {}
        new.prototype = item.prototype
        new.count = item.count
        return new
    end

    return self._inventory:modify(CACHE_NAMES, prototype, clone)
end

return function ()
    local M = {}
    M._inventory = create_cache(CACHE_NAMES, "prototype")

    M.flush = flush
    M.get = get
    M.decrease = decrease
    M.modity = modity
    M.revert = revert
    M.confirm = confirm
    M.complete = complete
    return M
end