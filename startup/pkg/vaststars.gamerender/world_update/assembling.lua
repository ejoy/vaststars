local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local objects = require "objects"
local global = require "global"
local iprototype = require "gameplay.interface.prototype"
local prefab_slots = require("engine.prefab_parser").slots
local prefab_meshbin = require("engine.prefab_parser").meshbin
local iheapmesh = ecs.import.interface "ant.render|iheapmesh"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local building_io_slots = import_package "vaststars.prototype"("building_io_slots")
local assetmgr = import_package "ant.asset"
local iterrain = ecs.require "terrain"
local icanvas = ecs.require "engine.canvas"
local datalist = require "datalist"
local fs = require "filesystem"
local recipe_icon_canvas_cfg = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/recipe_icon_canvas.cfg")):read "a")

local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local HEAP_DIM3 = {2, 4, 2}
local PREFABS = {
    ["in"]  = "/pkg/vaststars.resources/prefabs/shelf-input.prefab",
    ["out"] = "/pkg/vaststars.resources/prefabs/shelf-output.prefab",
}

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

local function create_io_shelves(gameplay_world, e, building_srt)
    local typeobject_recipe = iprototype.queryById(e.assembling.recipe)
    local typeobject_building = iprototype.queryById(e.building.prototype)
    local ingredients_n <const> = #typeobject_recipe.ingredients//4 - 1
    local results_n <const> = #typeobject_recipe.results//4 - 1
    local key = ("%s%s"):format(ingredients_n, results_n)
    local cfg = assert(building_io_slots[key])

    if typeobject_building.io_shelf == false then
        return {
            on_position_change = function() end,
            remove = function() end,
            recipe = typeobject_recipe.id,
            update_heap_count = function() end,
        }
    end

    local shelves = {}
    local shelf_offsets = {}
    local heap_offsets = {}
    local heaps = {}
    local io_counts = {}

    local building_slots = prefab_slots("/pkg/vaststars.resources/" .. typeobject_building.model)
    for _, io in ipairs({"in", "out"}) do
        local prefab = PREFABS[io]
        for _, idx in ipairs(cfg[io .. "_slots"]) do
            local prefab_instance = ecs.create_instance(prefab)
            local slots = prefab_slots(prefab)
            assert(building_slots["shelf" .. idx], "prefab(" .. prefab .. ") has no 'shelf" .. idx .. "' slot")
            local scene = building_slots["shelf" .. idx].scene
            local offset = math3d.ref(math3d.matrix {s = scene.s, r = scene.r, t = scene.t})
            function prefab_instance:on_ready()
                local e <close> = w:entity(self.tag["*"][1])
                iom.set_srt_matrix(e, math3d.mul(building_srt, offset))
            end
            function prefab_instance:on_message()
            end
            shelves[#shelves+1] = world:create_object(prefab_instance)

            shelf_offsets[#shelf_offsets+1] = offset
            heap_offsets[#heap_offsets+1] = math3d.ref(math3d.matrix {s = slots["pile_slot"].scene.s, r = slots["pile_slot"].scene.r, t = slots["pile_slot"].scene.t})
        end
    end

    for idx = 1, ingredients_n do
        local id = string.unpack("<I2I2", typeobject_recipe.ingredients, 4*idx+1)
        local typeobject_item = iprototype.queryById(id)
        local gap3 = typeobject_item.gap3 and {typeobject_item.gap3:match("(%d+)x(%d+)x(%d+)")} or {0, 0, 0}
        local srt = math3d.mul(building_srt, shelf_offsets[#heaps+1])
        srt = math3d.mul(srt, heap_offsets[#heaps+1])
        local s, r, t = math3d.srt(srt)
        srt = {s = s, r = r, t = t}
        local prefab = "/pkg/vaststars.resources/" .. typeobject_item.pile_model
        local slot = assert(gameplay_world:container_get(e.chest, idx))
        heaps[#heaps+1] = create_heap(prefab_meshbin(prefab)[1], srt, HEAP_DIM3, gap3, slot.amount)
        io_counts[#io_counts+1] = slot.amount
    end
    for idx = 1, results_n do
        local id = string.unpack("<I2I2", typeobject_recipe.results, 4*idx+1)
        local typeobject_item = iprototype.queryById(id)
        local gap3 = typeobject_item.gap3 and {typeobject_item.gap3:match("(%d+)x(%d+)x(%d+)")} or {0, 0, 0}
        local srt = math3d.mul(building_srt, shelf_offsets[#heaps+1])
        srt = math3d.mul(srt, heap_offsets[#heaps+1])
        local s, r, t = math3d.srt(srt)
        srt = {s = s, r = r, t = t}
        local prefab = "/pkg/vaststars.resources/" .. typeobject_item.pile_model
        local slot = assert(gameplay_world:container_get(e.chest, idx + ingredients_n))
        heaps[#heaps+1] = create_heap(prefab_meshbin(prefab)[1], srt, HEAP_DIM3, gap3, slot.amount)
        io_counts[#io_counts+1] = slot.amount
    end

    local function update_heap_count(_, e)
        if typeobject_building.io_shelf == false then
            return
        end

        for idx = 1, ingredients_n do
            local slot = assert(gameplay_world:container_get(e.chest, idx))
            if io_counts[idx] ~= slot.amount then
                iheapmesh.update_heap_mesh_number(heaps[idx].id, slot.amount)
                io_counts[idx] = slot.amount
            end
        end
        for idx = 1, results_n do
            local io_idx = idx + ingredients_n
            local slot = assert(gameplay_world:container_get(e.chest, io_idx))
            if io_counts[io_idx] ~= slot.amount then
                iheapmesh.update_heap_mesh_number(heaps[idx].id, slot.amount)
                io_counts[io_idx] = slot.amount
            end
        end
    end
    local function remove(self)
        for _, o in ipairs(shelves) do
            o:remove()
        end
        for _, o in ipairs(heaps) do
            o:remove()
        end
    end
    local function on_position_change(self, building_srt)
        -- TODO: when the building position changes, update the location
    end
    return {
        on_position_change = on_position_change,
        remove = remove,
        recipe = typeobject_recipe.id,
        update_heap_count = update_heap_count,
    }
end

local ICON_STATUS_NOPOWER <const> = 1
local ICON_STATUS_NORECIPE <const> = 2
local ICON_STATUS_RECIPE <const> = 3

local function _get_texture_size(materialpath)
    local res = assetmgr.resource(materialpath)
    local texobj = assetmgr.resource(res.properties.s_basecolor.texture)
    local ti = texobj.texinfo
    return ti.width, ti.height
end

local function _get_rect(x, y, icon_w, icon_h)
    y = y - iterrain.tile_size
    local max = math.max(icon_h, icon_w)
    local draw_w = iterrain.tile_size * (icon_w / max)
    local draw_h = iterrain.tile_size * (icon_h / max)
    local draw_x = x + (iterrain.tile_size - draw_w) / 2
    local draw_y = y + (iterrain.tile_size - draw_h) / 2
    return draw_x, draw_y, draw_w, draw_h
end

local function __draw_icon(e, object_id, building_srt, status, recipe)
    local x, y = building_srt.t[1], building_srt.t[3]
    if status == ICON_STATUS_NOPOWER then
        local material_path = "/pkg/vaststars.resources/materials/blackout.material"
        local icon_w, icon_h = _get_texture_size(material_path)
        local draw_x, draw_y, draw_w, draw_h = _get_rect(x - (iterrain.tile_size // 2), y + (iterrain.tile_size // 2), icon_w, icon_h)
        icanvas.add_item(icanvas.types().ICON,
            object_id,
            material_path,
            RENDER_LAYER.ICON_CONTENT,
            {
                texture = {
                    rect = {
                        x = 0,
                        y = 0,
                        w = icon_w,
                        h = icon_h,
                    },
                },
                x = draw_x, y = draw_y, w = draw_w, h = draw_h,
            }
        )
    else
        local typeobject = iprototype.queryById(e.building.prototype)
        if typeobject.assembling_icon == false then
            return
        end
        if status == ICON_STATUS_NORECIPE then
            local material_path = "/pkg/vaststars.resources/materials/setup2.material"
            local icon_w, icon_h = _get_texture_size(material_path)
            local texture_x, texture_y, texture_w, texture_h = 0, 0, icon_w, icon_h
            local draw_x, draw_y, draw_w, draw_h = _get_rect(x - (iterrain.tile_size // 2), y + (iterrain.tile_size // 2), icon_w, icon_h)
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
        else
            local material_path
            local icon_w, icon_h
            local draw_x, draw_y, draw_w, draw_h
            local texture_x, texture_y, texture_w, texture_h

            material_path = "/pkg/vaststars.resources/materials/recipe_icon_bg.material"
            icon_w, icon_h = _get_texture_size(material_path)
            texture_x, texture_y, texture_w, texture_h = 0, 0, icon_w, icon_h
            draw_x, draw_y, draw_w, draw_h = _get_rect(x - (iterrain.tile_size // 2), y + (iterrain.tile_size // 2), icon_w, icon_h)
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

            local recipe_typeobject = assert(iprototype.queryById(recipe))
            local cfg = recipe_icon_canvas_cfg[recipe_typeobject.recipe_icon]
            if not cfg then
                assert(cfg, ("can not found `%s`"):format(recipe_typeobject.recipe_icon))
                return
            end
            material_path = "/pkg/vaststars.resources/materials/recipe_icon_canvas.material"
            texture_x, texture_y, texture_w, texture_h = cfg.x, cfg.y, cfg.width, cfg.height
            draw_x, draw_y, draw_w, draw_h = _get_rect(x - (iterrain.tile_size // 2), y + (iterrain.tile_size // 2), cfg.width, cfg.height)
            icanvas.add_item(icanvas.types().ICON,
                object_id,
                material_path,
                RENDER_LAYER.ICON_CONTENT,
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
    end
end

local function create_icon(object_id, e, building_srt)
    local status = 0
    local recipe = 0

    local function on_position_change(self, building_srt)
        icanvas.remove_item(icanvas.types().ICON, object_id)
        __draw_icon(e, object_id, building_srt, status, recipe)
    end
    local function remove(self)
        icanvas.remove_item(icanvas.types().ICON, object_id)
    end
    local function update(self, e)
        local s
        if e.capacitance.network == 0 then
            s = ICON_STATUS_NOPOWER
        else
            if e.assembling.recipe == 0 then
                s = ICON_STATUS_NORECIPE
            else
                s = ICON_STATUS_RECIPE
            end
        end

        if s == status and recipe == e.assembling.recipe then
            return
        end

        status, recipe = s, e.assembling.recipe
        icanvas.remove_item(icanvas.types().ICON, object_id)
        __draw_icon(e, object_id, building_srt, status, recipe)
    end
    return {
        on_position_change = on_position_change,
        remove = remove,
        update = update,
    }
end

return function(world)
    for e in world.ecs:select "assembling:in chest:in building:in capacitance:in eid:in" do
        local object = assert(objects:coord(e.building.x, e.building.y))
        local mat = math3d.ref(math3d.matrix {s = object.srt.s, r = object.srt.r, t = object.srt.t})
        local building = global.buildings[object.id]

        if not building.io_shelves then
            if e.assembling.recipe ~= 0 then
                building.io_shelves = create_io_shelves(world, e, mat)
            end
        else
            if e.assembling.recipe == 0 then
                if building.io_shelves.recipe ~= 0 then
                    building.io_shelves:remove()
                    building.io_shelves = nil
                end
            else
                if building.io_shelves.recipe ~= e.assembling.recipe then
                    building.io_shelves:remove()
                    building.io_shelves = create_io_shelves(world, e, mat)
                else
                    building.io_shelves:update_heap_count(e)
                end
            end
        end

        if not building.assembling_icon then
            building.assembling_icon = create_icon(object.id, e, object.srt)
        end
        building.assembling_icon:update(e)
    end
end