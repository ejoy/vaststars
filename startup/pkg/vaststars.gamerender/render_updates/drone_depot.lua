local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local objects = require "objects"
local global = require "global"
local iprototype = require "gameplay.interface.prototype"
local prefab_meshbin = require("engine.prefab_parser").meshbin
local iheapmesh = ecs.require "ant.render|render_system.heap_mesh"
local ientity_object = ecs.require "engine.system.entity_object_system"
local ichest = require "gameplay.interface.chest"
local prefab_slots = require("engine.prefab_parser").slots
local iom = ecs.require "ant.objcontroller|obj_motion"
local gameplay_core = require "gameplay.core"
local drone_depot_sys = ecs.system "drone_depot_systme"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local ipower_check = ecs.require "power_check_system"

local PILE_SLOT_NAMES <const> = {
    [1] = {"pile_slot"},
    [2] = {"pile_slot_1", "pile_slot_2"},
}

local DIM3_CONVERTERS <const> = {
    [1] = function(item)
        local typeobject_item = iprototype.queryById(item)
        local pile = typeobject_item.pile
        return { (pile>>24) & 0xff, (pile>>32) & 0xff, (pile>>40) & 0xff }
    end,
    [2] = function(item)
        local typeobject_item = iprototype.queryById(item)
        local pile = typeobject_item.pile
        return { ((pile>>24) & 0xff) // 2, (pile>>32) & 0xff, (pile>>40) & 0xff }
    end,
}

local function __get_gap3(typeobject)
    if typeobject.drone_depot_gap3 then
        return {typeobject.drone_depot_gap3:match("([%d%.]+)x([%d%.]*)x([%d%.]*)")}
    end
    return typeobject.gap3 and {typeobject.gap3:match("([%d%.]+)x([%d%.]*)x([%d%.]*)")} or {0, 0, 0}
end

local events = {}
events["obj_motion"] = function(_, e, method, ...)
    iom[method](e, ...)
end

local function create_heap(mesh, srt, dim3, gap3, count)
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
            mesh = mesh,
            heapmesh = {
                curSideSize = dim3,
                curHeapNum = count,
                interval = gap3,
            },
            indirect = "HEAP_MESH",
            render_layer = RENDER_LAYER.HEAP_ITEM,
        },
    }, events)
end

local function create_shelf(building, item, count, building_srt, slot_name, pile_dim3)
    local typeobject_building = iprototype.queryById(building)
    local building_slots = prefab_slots("/pkg/vaststars.resources/" .. typeobject_building.model)
    assert(building_slots[slot_name])
    local scene = building_slots[slot_name].scene
    local offset = math3d.ref(math3d.matrix {s = scene.s, r = scene.r, t = scene.t})

    local typeobject_item = iprototype.queryById(item)
    local meshbin = assert(prefab_meshbin("/pkg/vaststars.resources/" .. typeobject_item.pile_model))
    local gap3 = __get_gap3(typeobject_item)
    local srt = math3d.mul(math3d.matrix({s = building_srt.s, r = building_srt.r, t = building_srt.t}), offset)
    local s, r, t = math3d.srt(srt)
    srt = {s = s, r = r, t = t}
    local heap = create_heap(meshbin[1].mesh, srt, pile_dim3, gap3, count)

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
local NO_RECIPE_MATERIAL_PATH <const> = "/pkg/vaststars.resources/materials/canvas/no-recipe.material"
local NO_POWER_MATERIAL_PATH <const> = "/pkg/vaststars.resources/materials/canvas/no-power.material"

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

local function __draw_icon(object_id, x, y, material_path)
    local icon_w, icon_h = __get_texture_size(material_path)
    local texture_x, texture_y, texture_w, texture_h = 0, 0, icon_w, icon_h
    local draw_x, draw_y, draw_w, draw_h = __get_draw_rect(x, y, icon_w, icon_h, 1.5)
    icanvas.add_item(icanvas.types().ICON,
        object_id,
        icanvas.get_key(material_path, RENDER_LAYER.ICON),
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

local function create_icon(object_id)
    local cache_not_set_item
    local cache_no_power

    local function remove(self)
        cache_not_set_item = nil
        cache_no_power = nil
        icanvas.remove_item(icanvas.types().ICON, object_id)
    end
    local function update(self, building_srt, not_set_item, no_power)
        if not_set_item == cache_not_set_item and no_power == cache_no_power then
            return
        end
        cache_not_set_item = not_set_item
        cache_no_power = no_power

        remove(self)

        if not not_set_item and not no_power then
            return
        end
        local x, y = building_srt.t[1], building_srt.t[3]
        if no_power then
            __draw_icon(object_id, x, y, NO_POWER_MATERIAL_PATH)
        else
            __draw_icon(object_id, x, y, NO_RECIPE_MATERIAL_PATH)
        end
    end
    local function on_position_change(self, building_srt)
        remove(self)
        update(self, building_srt, cache_not_set_item)
    end
    return {
        on_position_change = on_position_change,
        remove = remove,
        update = update,
    }
end

function drone_depot_sys:gameworld_update()
    local world = gameplay_core.get_world()
    for e in world.ecs:select "hub:in building:in eid:in" do
        -- object may not have been fully created yet
        local object = objects:coord(e.building.x, e.building.y)
        if not object then
            goto continue
        end

        local building = global.buildings[object.id]
        local not_set_item = true

        local heap_count = 0
        for i = 1, ichest.MAX_SLOT do
            local slot = world:container_get(e.hub, i)
            if not slot then
                break
            end

            if slot.item ~= 0 then
                heap_count = heap_count + 1
                not_set_item = false
            end
        end

        --
        local shelves = building.drone_depot_shelves
        if shelves then
            if shelves.heap_count == heap_count then
                for i = 1, heap_count do
                    local slot = world:container_get(e.hub, i)
                    if not slot then
                        break
                    end

                    local amount = ichest.get_amount(slot)
                    if shelves[i] and shelves[i].item == slot.item then
                        if shelves[i].count ~= amount then
                            shelves[i]:update(slot.amount)
                        end
                    else
                        if shelves[i] then
                            shelves[i]:remove()
                        end
                        shelves[i] = create_shelf(e.building.prototype, slot.item, slot.amount, object.srt, PILE_SLOT_NAMES[heap_count][i], DIM3_CONVERTERS[heap_count](slot.item))
                    end
                end
            else
                for i = 1, heap_count do
                    local slot = world:container_get(e.hub, i)
                    if not slot then
                        break
                    end

                    local amount = ichest.get_amount(slot)
                    if shelves[i] then
                        shelves[i]:remove()
                    end
                    shelves[i] = create_shelf(e.building.prototype, slot.item, amount, object.srt, PILE_SLOT_NAMES[heap_count][i], DIM3_CONVERTERS[heap_count](slot.item))
                end
            end

            if shelves.heap_count ~= heap_count then
                for i = heap_count + 1, #shelves do
                    if shelves[i] then
                        shelves[i]:remove()
                        shelves[i] = nil
                    end
                end
            end
            shelves.heap_count = heap_count
        else
            local t = {
                remove = function(self)
                    for i = 1, #self do
                        self[i]:remove()
                    end
                end,
                on_position_change = function(self, building_srt)
                    for i = 1, #self do
                        self[i]:on_position_change(building_srt)
                    end
                end,
                heap_count = heap_count,
            }
            for i = 1, ichest.MAX_SLOT do
                local slot = ichest.get(world, e.hub, i)
                if not slot then
                    break
                end
                if slot.item ~= 0 then
                    assert(PILE_SLOT_NAMES[heap_count] and PILE_SLOT_NAMES[heap_count][i])
                    assert(DIM3_CONVERTERS[heap_count])
                    t[i] = create_shelf(e.building.prototype, slot.item, slot.amount, object.srt, PILE_SLOT_NAMES[heap_count][i], DIM3_CONVERTERS[heap_count](slot.item))
                end
            end

            building.drone_depot_shelves = t
        end

        --

        local no_power = not ipower_check.is_powered_on(e.eid)
        building.drone_depot_icon = building.drone_depot_icon or create_icon(object.id)
        building.drone_depot_icon:update(object.srt, not_set_item, no_power)

        ::continue::
    end
end