local iprototype = require "gameplay.interface.prototype"

return function ()
    local function length(t)
        local n = 0
        for _ in pairs(t) do
            n = n + 1
        end
        return n
    end
    local mt = {}
    function mt:__index(k)
        local v = {}
        rawset(self, k, v)
        return v
    end
    local unlocked_tech = setmetatable({}, mt)
    for _, typeobject in pairs(iprototype.each_type "tech") do
        if typeobject.effects and typeobject.effects.unlock_item then
            for _, prototype_name in ipairs(typeobject.effects.unlock_item) do
                unlocked_tech[prototype_name][typeobject.name] = true
            end
        end
    end
    for _, typeobject in pairs(iprototype.each_type "task") do
        if typeobject.effects and typeobject.effects.unlock_item then
            for _, prototype_name in ipairs(typeobject.effects.unlock_item) do
                unlocked_tech[prototype_name][typeobject.name] = true
            end
        end
    end
    for prototype_name, v in pairs(unlocked_tech) do
        if length(v) > 1 then
            error(("prototype `%s` is unlocked by multiple techs: %s"):format(prototype_name, table.concat(v, ", ")))
        end
    end

    return unlocked_tech
end