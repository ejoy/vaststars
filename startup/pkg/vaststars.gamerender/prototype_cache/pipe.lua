local mt = {}
mt.__index = function (t, k)
    t[k] = {}
    return t[k]
end

return function()
    local iprototype = require "gameplay.interface.prototype"

    local accel = setmetatable({}, mt)
    local accel_rev = setmetatable({}, mt)
    for _, typeobject in pairs(iprototype.each_type "pipe") do
        assert(typeobject.building_direction)
        for _, entity_dir in ipairs(typeobject.building_direction) do
            local m = 0
            for _, connection in ipairs(typeobject.fluidbox.connections) do
                local dir = iprototype.rotate_dir(connection.position[3], entity_dir)
                m = m | (1 << dir)
            end

            assert(not accel[typeobject.building_category][m])
            accel[typeobject.building_category][m] = {prototype_name = typeobject.name, entity_dir = entity_dir}

            assert(not accel_rev[typeobject.name][entity_dir])
            accel_rev[typeobject.name][entity_dir] = m
        end
    end

    local function MaskToPrototypeDir(building_category, mask)
        local c = accel[building_category][mask]
        return c.prototype_name, c.entity_dir
    end

    local function PrototypeDirToMask(prototype_name, dir)
        return accel_rev[prototype_name][dir]
    end

    return {
        MaskToPrototypeDir = MaskToPrototypeDir,
        PrototypeDirToMask = PrototypeDirToMask,
    }
end