local ecs = ...
local world = ecs.world

local gameplay_core = require "gameplay.core"
local ichest = require "gameplay.interface.chest"
local inner_building = require "editor.inner_building"
local iprototype = require "gameplay.interface.prototype"
local igameplay = ecs.require "gameplay.gameplay_system"
local objects = require "objects"
local iobject = ecs.require "object"
local global = require "global"
local DEBRIS <const> = ecs.require "vaststars.prototype|debris"

return function(gameplay_eid)
    local e = assert(gameplay_core.get_entity(gameplay_eid))

    local items = {}
    if e.chest then
        for i = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
            local slot = ichest.get(gameplay_core.get_world(), e.chest, i)
            if not slot then
                break
            end
            if slot.item ~= 0 and slot.amount > 0 then
                local typeobject = iprototype.queryById(slot.item)
                if not iprototype.is_fluid_id(slot.item) then
                    items[#items+1] = {typeobject.name, slot.amount}
                end
            end
        end
    end
    igameplay.destroy_entity(gameplay_eid)

    --TODO
    -- ibuilding.remove(x, y)
    -- iroadnet:del("road", x, y)
    -- gameplay_core.set_changed(CHANGED_FLAG_ROADNET)

    -- the road will not execute the following logic
    local typeobject = iprototype.queryById(e.building.prototype)
    local old_object = objects:coord(e.building.x, e.building.y)
    if old_object then
        iobject.remove(old_object)
        objects:remove(old_object.id)
        local building = global.buildings[old_object.id]
        if building then
            for _, v in pairs(building) do
                v:remove()
            end
        end

        local w, h = iprototype.rotate_area(typeobject.area, e.building.direction)
        for gameplay_eid in inner_building:get(e.building.x, e.building.y, w, h) do
            igameplay.destroy_entity(gameplay_eid)
        end

        if #items > 0 then
            local d = ("%sx%s"):format(w, h)
            -- Add a ruined building
            local new_object = iobject.new {
                prototype_name = DEBRIS[d] or error("No debris for " .. d),
                dir = old_object.dir,
                x = e.building.x,
                y = e.building.y,
                srt = old_object.srt,
                group_id = old_object.group_id,
                items = items,
                debris = e.building.prototype,
            }
            new_object.gameplay_eid = igameplay.create_entity(new_object)
            objects:set(new_object, "CONSTRUCTED")
        end
    end
end