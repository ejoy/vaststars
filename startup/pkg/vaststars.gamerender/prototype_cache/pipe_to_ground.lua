local DIRECTION <const> = require "gameplay.interface.constant".DIRECTION

local mt = {}
mt.__index = function (t, k)
    t[k] = {}
    return t[k]
end

return function()
    local iprototype = require "gameplay.interface.prototype"

    local accel = setmetatable({}, mt)
    local accel_rev = setmetatable({}, mt)

    for _, typeobject in pairs(iprototype.each_type "pipe_to_ground") do
        assert(typeobject.building_direction)
        for _, entity_dir in ipairs(typeobject.building_direction) do
            local m = 0
            for _, connection in ipairs(typeobject.fluidbox.connections) do
                local dir = iprototype.rotate_dir(connection.position[3], entity_dir)
                if connection.ground then
                    m = m | (2 << (dir*2))
                else
                    m = m | (1 << (dir*2))
                end
            end

            assert(not accel[typeobject.building_category][m])
            accel[typeobject.building_category][m] = {prototype = typeobject.id, entity_dir = DIRECTION[entity_dir]}

            assert(not accel_rev[typeobject.id][DIRECTION[entity_dir]])
            accel_rev[typeobject.id][DIRECTION[entity_dir]] = m
        end
    end

    local function MaskToPrototypeDir(building_category, mask)
        local c = accel[building_category][mask]
        return c.prototype, c.entity_dir
    end

    local function PrototypeDirToMask(prototype, dir)
        return accel_rev[prototype][dir]
    end

    return {
        MaskToPrototypeDir = MaskToPrototypeDir,
        PrototypeDirToMask = PrototypeDirToMask,
    }
end