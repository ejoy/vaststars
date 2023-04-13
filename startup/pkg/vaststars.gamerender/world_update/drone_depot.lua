local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local objects = require "objects"
local global = require "global"
local iprototype = require "gameplay.interface.prototype"
local prefab_meshbin = require("engine.prefab_parser").meshbin
local iheapmesh = ecs.import.interface "ant.render|iheapmesh"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local ichest = require "gameplay.interface.chest"
local prefab_slots = require("engine.prefab_parser").slots

local function create_heap(meshbin, srt, dim3, gap3, count)
    return ientity_object.create(ecs.create_entity {
        policy = {
            "ant.render|render",
            "ant.general|name",
            "ant.render|heap_mesh",
         },
        data = {
            name = "heap_items",
            scene   = srt,
            material = "/pkg/ant.resources/materials/pbr_heap.material",
            visible_state = "main_view",
            mesh = meshbin,
            heapmesh = {
                curSideSize = dim3,
                curHeapNum = count,
                interval = gap3,
            }
        },
    })
end

local function create_shelf(building, item, count, building_srt)
    local typeobject_building = iprototype.queryById(building)
    local building_slots = prefab_slots("/pkg/vaststars.resources/" .. typeobject_building.model)
    assert(building_slots["pile_slot"])
    local scene = building_slots["pile_slot"].scene
    local offset = math3d.ref(math3d.matrix {s = scene.s, r = scene.r, t = scene.t})

    local typeobject_item = iprototype.queryById(item)
    local meshbin = assert(prefab_meshbin("/pkg/vaststars.resources/" .. typeobject_item.pile_model))
    local dim3 = {typeobject_item.pile:match("(%d+)x(%d+)x(%d+)")}
    local gap3 = typeobject_item.gap3 and {typeobject_item.gap3:match("(%d+)x(%d+)x(%d+)")} or {0, 0, 0}
    local srt = math3d.mul(math3d.matrix({s = building_srt.s, r = building_srt.r, t = building_srt.t}), offset)
    local s, r, t = math3d.srt(srt)
    srt = {s = s, r = r, t = t}
    local heap = create_heap(meshbin[1], srt, dim3, gap3, count)

    local res = {item = item, count = count, heap = heap, offset = offset}
    res.on_position_change = function (self, building_srt)
        -- TODO: when the building position changes, update the location
    end
    res.update = function(self, count)
        iheapmesh.update_heap_mesh_number(heap.id, count)
        self.count = count
    end
    res.remove = function(self)
        heap:remove()
    end
    return res
end

return function(world)
    for e in world.ecs:select "hub:in building:in eid:in" do
        local object = assert(objects:coord(e.building.x, e.building.y))
        local building = global.buildings[object.id]
        local slot = ichest.chest_get(world, e.hub, 1)
        if building.drone_depot_shelf then
            if not slot then
                building.drone_depot_shelf:remove()
            else
                if building.drone_depot_shelf.item == slot.item then
                    if building.drone_depot_shelf.count ~= slot.amount then
                        building.drone_depot_shelf:update(slot.amount)
                    end
                else
                    building.drone_depot_shelf:remove()
                    building.drone_depot_shelf = create_shelf(e.building.prototype, slot.item, slot.amount, object.srt)
                end
            end
        else
            if slot then
                building.drone_depot_shelf = create_shelf(e.building.prototype, slot.item, slot.amount, object.srt)
            end
        end
    end
end