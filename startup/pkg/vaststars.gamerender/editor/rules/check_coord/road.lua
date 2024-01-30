local ecs = ...
local world = ecs.world

local imineral = ecs.require "mineral"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local imountain = ecs.require "engine.mountain"

return function (x, y, dir, typeobject, exclude_coords)
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    exclude_coords = exclude_coords or {}

    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local dx, dy = x + i, y + j
            local object = objects:coord(dx, dy)
            if object then
                return false, "cannot place here"
            end

            if imineral.get(dx, dy) then
                return false, "cannot place here"
            end

            if imountain:has_mountain(dx, dy) then
                return false, "cannot place here"
            end
        end
    end
    return true
end