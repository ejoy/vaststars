local ecs = ...
local world = ecs.world

local ibuilding = ecs.require "render_updates.building"
local imineral = ecs.require "mineral"
local objects = require "objects"
local imining = require "gameplay.interface.mining"
local iprototype = require "gameplay.interface.prototype"

return function (x, y, dir, typeobject, exclude_object_id)
    local w, h = iprototype.rotate_area(typeobject.area, dir)

    local found_mineral
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local object = objects:coord(x + i, y + j)

            -- building
            if object and object.id ~= exclude_object_id then
                return false, "cannot place here"
            end

            -- road
            if ibuilding.get(x + i, y + j) then
                return false, "cannot place here"
            end

            --TODO: this assumes that each coordinate will only have one type of mineral
            if not found_mineral then
                found_mineral = imineral.get(x + i, y + j)
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
        local r = imining.get_mineral_recipe(typeobject.name, mineral) ~= nil
        if r then
            return true
        else
            return false, "needs to be placed above a resource mine"
        end
    end
end