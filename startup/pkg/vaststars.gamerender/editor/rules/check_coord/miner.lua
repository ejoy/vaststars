local ecs = ...
local world = ecs.world

local ibuilding = ecs.require "render_updates.building"
local imineral = ecs.require "mineral"
local objects = require "objects"
local iminer = require "gameplay.interface.miner"
local iprototype = require "gameplay.interface.prototype"
local icoord = require "coord"

return function (x, y, dir, typeobject, exclude_coords)
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    exclude_coords = exclude_coords or {}

    local found_mineral
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local dx, dy = x + i, y + j
            if not exclude_coords[icoord.pack(dx, dy)] then
                -- building
                if objects:coord(dx, dy) then
                    return false, "cannot place here"
                end

                -- road
                if ibuilding.get(dx, dy) then
                    return false, "cannot place here"
                end
            end

            --TODO: this assumes that each coordinate will only have one type of mineral
            if not found_mineral then
                found_mineral = imineral.get(dx, dy)
            end
        end
    end

    if not found_mineral then
        return false, "needs to be placed above a resource mine"
    else
        local succ, mineral = imineral.can_place(x, y, w, h)
        if not succ then
            return false, "needs to be placed above a resource mine"
        end
        local r = iminer.get_mineral_recipe(typeobject.name, mineral) ~= nil
        if r then
            return true
        else
            return false, "needs to be placed above a resource mine"
        end
    end
end