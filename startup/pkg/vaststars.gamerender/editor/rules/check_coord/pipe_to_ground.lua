local ecs = ...
local world = ecs.world

local ibuilding = ecs.require "render_updates.building"
local imineral = ecs.require "mineral"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"

return function (prototype_name, x, y, w, h, object_id)
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local object = objects:coord(x + i, y + j)

            -- building
            if object and object.id ~= object_id then
                local typeobject = iprototype.queryByName(object.prototype_name)
                if iprototype.has_types(typeobject.type, "pipe", "pipe_to_ground") then
                    goto continue
                end
                return false
            end

            -- road
            if ibuilding.get((x + i)//2*2, (y + j)//2*2) then
                return false
            end

            -- mineral
            if imineral.get(x + i, y + j) then
                return false
            end
            ::continue::
        end
    end
    return true
end