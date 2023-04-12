local ecs, mailbox = ...
local world = ecs.world
local logistic_coord = ecs.require "terrain"
local selected_boxes = ecs.require "selected_boxes"
local objects = require "objects"
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"

local M = {}
local selects = {}

local function select_cover(x, y, dist, obj)
    local e = gameplay_core.get_entity(obj.gameplay_eid)
    if e.chest or e.hub then
        local tobj = iprototype.queryByName(obj.prototype_name)
        local w, h = iprototype.unpackarea(tobj.area)
        local dx = obj.x + (w - 1) / 2 - x
        local dy = obj.y + (h - 1) / 2 - y
        if math.sqrt(dx * dx + dy * dy) <= dist and not selects[obj.id] then
            selects[obj.id] = selected_boxes("prefabs/selected_box_valid.prefab", logistic_coord:get_position_by_coord(obj.x, obj.y, w, h), w, h)
        end
    end
end

function M.update_cover(drone, typeobject)
    local aw, ah = iprototype.unpackarea(typeobject.area)
    local sw, sh = iprototype.unpackarea(typeobject.supply_area)
    local min_x = drone.x - (sw - (aw + 1)//2)
    local max_x = drone.x + aw - 1 + (sw - (aw + 1)//2)
    local min_y = drone.y - (sh - (ah + 1)//2)
    local max_y = drone.y + ah - 1 + (sh - (ah + 1)//2)
    local centre_x = drone.x + (aw - 1) / 2
    local centre_y = drone.y + (ah - 1) / 2
    for _, s in pairs(selects) do
        s:remove()
    end
    selects = {}
    for x = min_x, max_x do
        for y = min_y, max_y do
            local obj = objects:coord(x, y)
            if obj and obj.id ~= drone.id then
                select_cover(centre_x, centre_y, sw, obj)
            end
        end
    end
end

function M.clear()
    for _, s in pairs(selects) do
        s:remove()
    end
    selects = {}
end

return M