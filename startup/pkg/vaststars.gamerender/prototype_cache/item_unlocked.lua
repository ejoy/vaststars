local ecs = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local iprototype_cache = ecs.require "prototype_cache"

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
    for name in pairs(iprototype_cache.get_techs()) do
        local typeobject = iprototype.queryByName(name)
        if typeobject.effects and typeobject.effects.unlock_item then
            for _, prototype_name in ipairs(typeobject.effects.unlock_item) do
                unlocked_tech[prototype_name][typeobject.name] = true
            end
        end
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