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
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"

local events = {}
events["obj_motion"] = function(_, e, method, ...)
    iom[method](e, ...)
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
    }, events)
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
        local srt = math3d.mul(math3d.matrix({s = building_srt.s, r = building_srt.r, t = building_srt.t}), offset)
        local s, r, t = math3d.srt(srt)
        heap:send("obj_motion", "set_srt", math3d.ref(s), math3d.ref(r), math3d.ref(t))
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

-- TODO: duplicate code with assembling.lua
local assetmgr = import_package "ant.asset"
local iterrain = ecs.require "terrain"
local icanvas = ecs.require "engine.canvas"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

local function __get_texture_size(materialpath)
    local res = assetmgr.resource(materialpath)
    local texobj = assetmgr.resource(res.properties.s_basecolor.texture)
    local ti = texobj.texinfo
    return ti.width, ti.height
end

local function __get_draw_rect(x, y, icon_w, icon_h, multiple)
    local tile_size = iterrain.tile_size * multiple
    multiple = multiple or 1
    y = y - tile_size
    local max = math.max(icon_h, icon_w)
    local draw_w = tile_size * (icon_w / max)
    local draw_h = tile_size * (icon_h / max)
    local draw_x = x - (tile_size / 2)
    local draw_y = y + (tile_size / 2)
    return draw_x, draw_y, draw_w, draw_h
end

local function __draw_icon(object_id, x, y)
    local material_path = "/pkg/vaststars.resources/materials/setup2.material"
    local icon_w, icon_h = __get_texture_size(material_path)
    local texture_x, texture_y, texture_w, texture_h = 0, 0, icon_w, icon_h
    local draw_x, draw_y, draw_w, draw_h = __get_draw_rect(x, y, icon_w, icon_h, 1.5)
    icanvas.add_item(icanvas.types().ICON,
        object_id,
        material_path,
        RENDER_LAYER.ICON,
        {
            texture = {
                rect = {
                    x = texture_x,
                    y = texture_y,
                    w = texture_w,
                    h = texture_h,
                },
            },
            x = draw_x, y = draw_y, w = draw_w, h = draw_h,
        }
    )
end

local function create_icon(object_id, e)
    local cache

    local function remove(self)
        icanvas.remove_item(icanvas.types().ICON, object_id)
    end
    local function on_position_change(self, building_srt)
        remove(self)
        local x, y = building_srt.t[1], building_srt.t[3]
        __draw_icon(object_id, x, y)
    end
    local function update(self, building_srt, item)
        if item == cache then
            return
        end
        cache = item

        if item ~= 0 then
            remove(self)
            return
        end
        local x, y = building_srt.t[1], building_srt.t[3]
        __draw_icon(object_id, x, y)
    end
    return {
        on_position_change = on_position_change,
        remove = remove,
        update = update,
    }
end

return function(world)
    for e in world.ecs:select "hub:in building:in eid:in" do
        -- object may not have been fully created yet
        local object = objects:coord(e.building.x, e.building.y)
        if not object then
            goto continue
        end

        local building = global.buildings[object.id]
        local slot = ichest.chest_get(world, e.hub, 1)

        --
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

        --
        if not building.drone_depot_icon then
            building.drone_depot_icon = create_icon(object.id, e)
        end
        if not slot then
            building.drone_depot_icon:update(object.srt, 0)
        else
            building.drone_depot_icon:update(object.srt, slot.item)
        end

        ::continue::
    end
end