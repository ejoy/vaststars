local ecs = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local iprototype_cache = ecs.require "prototype_cache"
local gameplay_core = require "gameplay.core"

return function ()
    local mt = {}
    function mt:__index(k)
        local v = {}
        rawset(self, k, v)
        return v
    end

    local function length(t)
        local n = 0
        for _ in pairs(t) do
            n = n + 1
        end
        return n
    end

    local unlocked_tech = setmetatable({}, mt)
    local function _insert_unlocked_tech(name)
        local typeobject = iprototype.queryByName(name)
        if typeobject.effects and typeobject.effects.unlock_recipe then
            for _, prototype_name in ipairs(typeobject.effects.unlock_recipe) do
                unlocked_tech[prototype_name][typeobject.name] = true
            end
        end
    end

    for name in pairs(iprototype_cache.get_techs()) do
        _insert_unlocked_tech(name)
    end

    local game_template = gameplay_core.get_storage().game_template
    local login_techs = ecs.require(("vaststars.prototype|%s"):format(game_template)).login_techs or {}
    for _, name in ipairs(login_techs) do
        _insert_unlocked_tech(name)
    end

    for prototype_name, v in pairs(unlocked_tech) do
        if length(v) > 1 then
            local t = {}
            for k in pairs(v) do
                table.insert(t, k)
            end
            error(("prototype `%s` is unlocked by multiple techs: %s"):format(prototype_name, table.concat(t, ", ")))
        end
    end

    return unlocked_tech
end