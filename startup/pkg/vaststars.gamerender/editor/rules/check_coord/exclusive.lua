local ecs = ...
local world = ecs.world

local ibuilding = ecs.require "render_updates.building"
local imineral = ecs.require "mineral"
local objects = require "objects"

return function (x, y, w, h, object_id)
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local object = objects:coord(x + i, y + j)

            -- building
            if object and object.id ~= object_id then
                return false
            end

            -- road
            if ibuilding.get(x + i, y + j) then
                return false
            end

            -- mineral
            if imineral.get(x + i, y + j) then
                return false
            end
        end
    end
    return true
end