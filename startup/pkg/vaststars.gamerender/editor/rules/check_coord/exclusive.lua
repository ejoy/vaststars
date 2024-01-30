local ecs = ...
local world = ecs.world

local ibuilding = ecs.require "render_updates.building"
local imineral = ecs.require "mineral"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local icoord = require "coord"

return function (x, y, dir, typeobject, exclude_coords)
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    exclude_coords = exclude_coords or {}

    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local dx, dy = x + i, y + j
            if not exclude_coords[iprototype.packcoord(dx, dy)] then
                -- building
                if objects:coord(dx, dy) then
                    return false, "cannot place here"
                end

                -- road
                if ibuilding.get(icoord.road_coord(x + i, y + j)) then
                    return false, "cannot place here"
                end
            end

            -- mineral
            if imineral.get(dx, dy) then
                return false, "cannot place here"
            end
        end
    end
    return true
end