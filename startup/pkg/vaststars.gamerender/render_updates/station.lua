local ecs = ...
local world = ecs.world
local w = world.w

local objects = require "objects"
local ichest = require "gameplay.interface.chest"
local global = require "global"
local iprototype = require "gameplay.interface.prototype"
local prefab_slots = require("engine.prefab_parser").slots
local prefab_meshbin = require("engine.prefab_parser").meshbin
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local iheapmesh = ecs.import.interface "ant.render|iheapmesh"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local math3d = require "math3d"
local station_sys = ecs.system "station_system"
local gameplay_core = require "gameplay.core"

local HEAP_DIM3 <const> = {2, 4, 2}

local function __calc_heap_srt(building_srt, slot_srt)
    local building_mat = math3d.matrix {s = building_srt.s, r = building_srt.r, t = building_srt.t}
    local mat = math3d.matrix {s = slot_srt.s, r = slot_srt.r, t = slot_srt.t}
    local mat = math3d.mul(building_mat, mat)
    return math3d.srt(mat)
end

local heap_events = {}
heap_events["set_srt"] = function(_, e, ...)
    iom.set_srt(e, __calc_heap_srt(...))
end

local function create_heap(meshbin, srt, dim3, gap3, count)
    return ientity_object.create(ecs.create_entity {
        policy = {
            "ant.render|render",
            "ant.general|name",
            "ant.render|heap_mesh",
         },
        data = {
            name = "heap_items",
            scene = srt,
            material = "/pkg/ant.resources/materials/pbr_heap.material",
            visible_state = "main_view",
            mesh = meshbin,
            heapmesh = {
                curSideSize = dim3,
                curHeapNum = count,
                interval = gap3,
            }
        },
    }, heap_events)
end

local function __create_station_shelf(building_srt, e, item_id, item_count)
    local typeobject_building = iprototype.queryById(e.building.prototype)
    if typeobject_building.io_shelf == false then
        return {
            on_position_change = function() end,
            remove = function() end,
            update_heap_count = function() end,
            item_id = item_id,
            item_count = item_count,
        }
    end

    if item_id == 0 then
        return {
            on_position_change = function() end,
            remove = function() end,
            update_heap_count = function() end,
            item_id = item_id,
            item_count = item_count,
        }
    end

    local slot = assert(prefab_slots("/pkg/vaststars.resources/" .. typeobject_building.model).shelf)
    local typeobject_item = iprototype.queryById(item_id)
    local gap3 = typeobject_item.gap3 and {typeobject_item.gap3:match("([%d%.]+)x([%d%.]*)x([%d%.]*)")} or {0, 0, 0}
    local prefab = "/pkg/vaststars.resources/" .. typeobject_item.pile_model
    local s, r, t = __calc_heap_srt(building_srt, slot.scene)

    local heap = create_heap(prefab_meshbin(prefab)[1].mesh, {s = s, r = r, t = t}, HEAP_DIM3, gap3, item_count)

    local function update_heap_count(self, c)
        if self.item_count == c then
            return
        end
        self.item_count = c
        iheapmesh.update_heap_mesh_number(heap.id, self.item_count)
    end
    local function remove()
        heap:remove()
    end
    local function on_position_change(self, building_srt)
        heap:send("set_srt", building_srt, slot.scene)
    end
    return {
        on_position_change = on_position_change,
        remove = remove,
        update_heap_count = update_heap_count,
        item_id = item_id,
        item_count = item_count,
    }
end

local function __get_item(gameplay_world, e)
    local slot = ichest.chest_get(gameplay_world, e.station, 1)
    if not slot then
        return 0, 0
    end
    return slot.item, ichest.get_amount(slot)
end

function station_sys:gameworld_update()
    local gameplay_world = gameplay_core.get_world()
    for e in gameplay_world.ecs:select "station:in building:in eid:in" do
        -- object may not have been fully created yet
        local object = objects:coord(e.building.x, e.building.y)
        if not object then
            goto continue
        end

        local station_shelf = assert(global.buildings[object.id]).station_shelf
        local item_id, item_count = __get_item(gameplay_world, e)
        if not station_shelf or station_shelf.item_id ~= item_id then
            if station_shelf then
                station_shelf:remove()
            end
            station_shelf = __create_station_shelf(object.srt, e, item_id, item_count)
            global.buildings[object.id].station_shelf = station_shelf
        end
        station_shelf:update_heap_count(item_count)
        ::continue::
    end
end