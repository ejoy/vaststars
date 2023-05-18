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
local fluid_icon_canvas_cfg = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/fluid_icon_canvas.cfg")):read "a")
local mc = import_package "ant.math".constant
local irecipe = require "gameplay.interface.recipe"
local gameplay_core = require "gameplay.core"
local ims = ecs.import.interface "ant.motion_sampler|imotion_sampler"
local ivs = ecs.import.interface "ant.scene|ivisible_state"
local imotion = ecs.require "imotion"
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local HEAP_DIM3 = {2, 4, 2}
local PREFABS = {
    ["in"]  = "/pkg/vaststars.resources/prefabs/shelf-input.prefab",
    ["out"] = "/pkg/vaststars.resources/prefabs/shelf-output.prefab",
}
local motions = {}
local motion_caches = {}
local function create_motion(prefab, from, to, duration, repeat_count)
    local cache = motion_caches[prefab]
    if not cache or #cache < 1 then
        local motion = imotion.create_motion_object(nil, nil, math3d.vector(from))
        imotion.sampler_group:create_instance(prefab, motion)
        return {inited = false, prefab = prefab, from = from, to = to, duration = duration, repeat_count = repeat_count, elapsed_time = 0, motion = motion }
    else
        local m = table.remove(cache, #cache)
        m.from = from
        m.to = to
        m.duration = duration
        m.repeat_count = 1
        m.elapsed_time = 0
        m.inited = false
        return m
    end
end

local heap_events = {}
heap_events["set_matrix"] = function(_, e, mat)
    iom.set_srt(e, math3d.srt(mat))
end

local function __create_heap(meshbin, srt, dim3, gap3, count)
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
    }, heap_events)
end

local function __create_io_shelves(object_id, gameplay_world, e, building_mat)
    local typeobject_recipe = iprototype.queryById(e.assembling.recipe)
    local typeobject_building = iprototype.queryById(e.building.prototype)
    local ingredients_n <const> = #typeobject_recipe.ingredients//4 - 1
    local results_n <const> = #typeobject_recipe.results//4 - 1
    local key = ("%s%s"):format(ingredients_n, results_n)

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

    local cfg = assert(building_io_slots[key])
    local building_slots = prefab_slots("/pkg/vaststars.resources/" .. typeobject_building.model)
    for _, io in ipairs({"in", "out"}) do
        local prefab = PREFABS[io]
        for slot_idx, idx in ipairs(cfg[io .. "_slots"]) do
            local id 
            if io == "in" then
                id = string.unpack("<I2I2", typeobject_recipe.ingredients, 4*slot_idx+1)
            else
                id = string.unpack("<I2I2", typeobject_recipe.results, 4*slot_idx+1)
            end
            local typeobject_item = iprototype.queryById(id)
            if iprototype.has_type(typeobject_item.type, "item") then
                local prefab_instance = ecs.create_instance(prefab)
                local slots = prefab_slots(prefab)
                assert(building_slots["shelf" .. idx], "prefab(" .. prefab .. ") has no 'shelf" .. idx .. "' slot")
                local scene = building_slots["shelf" .. idx].scene
                local offset = math3d.ref(math3d.matrix {s = scene.s, r = scene.r, t = scene.t})
                function prefab_instance:on_ready()
                    local e <close> = w:entity(self.tag["*"][1])
                    iom.set_srt(e, math3d.srt(math3d.mul(building_mat, offset)))
                end
                function prefab_instance:on_message(msg, ...)
                    local mat = ...
                    assert(msg == "set_matrix", "invalid message")
                    local e <close> = w:entity(self.tag["*"][1])
                    iom.set_srt(e, math3d.srt(mat))
                end
                shelves[#shelves+1] = world:create_object(prefab_instance)

                shelf_offsets[#shelf_offsets+1] = offset
                heap_offsets[#heap_offsets+1] = math3d.ref(math3d.matrix {s = slots["pile_slot"].scene.s, r = slots["pile_slot"].scene.r, t = slots["pile_slot"].scene.t})
            end
        end
    end

    for idx = 1, ingredients_n do
        local id = string.unpack("<I2I2", typeobject_recipe.ingredients, 4*idx+1)
        local typeobject_item = iprototype.queryById(id)
        if iprototype.has_type(typeobject_item.type, "item") then
            local gap3 = typeobject_item.gap3 and {typeobject_item.gap3:match("([%d%.]+)x([%d%.]*)x([%d%.]*)")} or {0, 0, 0}
            local mat = math3d.mul(math3d.mul(building_mat, shelf_offsets[#heaps+1]), heap_offsets[#heaps+1])
            local s, r, t = math3d.srt(mat)
            local prefab = "/pkg/vaststars.resources/" .. typeobject_item.pile_model
            local slot = assert(gameplay_world:container_get(e.chest, idx))
            heaps[#heaps+1] = __create_heap(prefab_meshbin(prefab)[1].meshbin, {s = s, r = r, t = t}, HEAP_DIM3, gap3, slot.amount)
            io_counts[#io_counts+1] = slot.amount
        end
    end
    for idx = 1, results_n do
        local id = string.unpack("<I2I2", typeobject_recipe.results, 4*idx+1)
        local typeobject_item = iprototype.queryById(id)
        if iprototype.has_type(typeobject_item.type, "item") then
            local gap3 = typeobject_item.gap3 and {typeobject_item.gap3:match("([%d%.]+)x([%d%.]*)x([%d%.]*)")} or {0, 0, 0}
            local mat = math3d.mul(math3d.mul(building_mat, shelf_offsets[#heaps+1]), heap_offsets[#heaps+1])
            local s, r, t = math3d.srt(mat)
            local prefab = "/pkg/vaststars.resources/" .. typeobject_item.pile_model
            local slot = assert(gameplay_world:container_get(e.chest, idx + ingredients_n))
            heaps[#heaps+1] = __create_heap(prefab_meshbin(prefab)[1].meshbin, {s = s, r = r, t = t}, HEAP_DIM3, gap3, slot.amount)
            io_counts[#io_counts+1] = slot.amount
        end
    end

    local function update_heap_count(self, e, building_srt)
        if typeobject_building.io_shelf == false then
            return
        end

        local typeobject_recipe = iprototype.queryById(e.assembling.recipe)

        for idx = 1, ingredients_n do
            local id = string.unpack("<I2I2", typeobject_recipe.ingredients, 4*idx+1)
            local typeobject_item = iprototype.queryById(id)
            if iprototype.has_type(typeobject_item.type, "item") then
                local slot = assert(gameplay_world:container_get(e.chest, idx))
                if io_counts[idx] ~= slot.amount then
                    local mat = math3d.matrix {s = mc.ONE, r = mc.IDENTITY_QUAT, t = building_srt.t}
                    local offset = self.shelf_offsets[idx]
                    local _, _, from = math3d.srt(math3d.mul(mat, offset))
                    from = math3d.ref(from)

                    -- 原料从货架到组装机中心的动画
                    if (io_counts[idx] or 0) > slot.amount then
                        -- motions[#motions + 1] = create_motion("/pkg/vaststars.resources/" .. typeobject_item.pile_model, from, building_srt.t, 1.0)
                    end
                    iheapmesh.update_heap_mesh_number(heaps[idx].id, slot.amount)
                    io_counts[idx] = slot.amount
                end
            end
        end
        for idx = 1, results_n do
            local id = string.unpack("<I2I2", typeobject_recipe.results, 4*idx+1)
            local typeobject_item = iprototype.queryById(id)
            if iprototype.has_type(typeobject_item.type, "item") then
                local io_idx = idx + ingredients_n
                local slot = assert(gameplay_world:container_get(e.chest, io_idx))
                if io_counts[io_idx] ~= slot.amount then
                    -- 成品从组装机中心到货架动画
                    if (io_counts[io_idx] or 0) < slot.amount then
                        local mat = math3d.matrix {s = mc.ONE, r = mc.IDENTITY_QUAT, t = building_srt.t}
                        local offset = self.shelf_offsets[idx]
                        local _, _, to = math3d.srt(math3d.mul(mat, offset))
                        to = math3d.ref(to)

                        -- motions[#motions + 1] = create_motion("/pkg/vaststars.resources/" .. typeobject_item.pile_model, building_srt.t, to, 1.0)
                    end
                    iheapmesh.update_heap_mesh_number(heaps[idx].id, slot.amount)
                    io_counts[io_idx] = slot.amount
                end
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
        local object = assert(objects:get(object_id))
        local mat = math3d.matrix {s = building_srt.s, r = ROTATORS[object.dir], t = building_srt.t}
        for idx, o in ipairs(self.shelves) do
            local offset = self.shelf_offsets[idx]
            o:send("set_matrix", math3d.ref(math3d.mul(mat, offset)))
        end

        for idx, o in ipairs(self.heaps) do
            local srt = math3d.mul(mat, self.shelf_offsets[idx])
            o:send("set_matrix", math3d.ref(math3d.mul(srt, heap_offsets[idx])))
        end
    end
    return {
        on_position_change = on_position_change,
        remove = remove,
        recipe = typeobject_recipe.id,
        update_heap_count = update_heap_count,
        object_id = object_id,
        shelf_offsets = shelf_offsets,
        shelves = shelves,
        heaps = heaps,
    }
end

local ICON_STATUS_NOPOWER <const> = 1
local ICON_STATUS_NORECIPE <const> = 2
local ICON_STATUS_RECIPE <const> = 3

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

local DIRECTION <const> = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
    [0] = 'N',
    [1] = 'E',
    [2] = 'S',
    [3] = 'W',
}

local function __calc_begin_xy(x, y, w, h)
    local tile_size = iterrain.tile_size
    local begin_x = x - (w * tile_size) / 2
    local begin_y = y + (h * tile_size) / 2
    return begin_x, begin_y
end

local function __draw_icon(e, object_id, building_srt, status, recipe)
    local x, y = building_srt.t[1], building_srt.t[3]
    if status == ICON_STATUS_NOPOWER then
        local material_path = "/pkg/vaststars.resources/materials/blackout.material"
        local icon_w, icon_h = __get_texture_size(material_path)
        local texture_x, texture_y, texture_w, texture_h = 0, 0, icon_w, icon_h
        local draw_x, draw_y, draw_w, draw_h = __get_draw_rect(x, y, icon_w, icon_h, 1.5)
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
    else
        local typeobject = iprototype.queryById(e.building.prototype)
        if status == ICON_STATUS_NORECIPE then
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
        else
            local material_path
            local icon_w, icon_h
            local draw_x, draw_y, draw_w, draw_h
            local texture_x, texture_y, texture_w, texture_h

            if typeobject.assembling_icon ~= false then
                material_path = "/pkg/vaststars.resources/materials/recipe_icon_bg.material"
                icon_w, icon_h = __get_texture_size(material_path)
                texture_x, texture_y, texture_w, texture_h = 0, 0, icon_w, icon_h
                draw_x, draw_y, draw_w, draw_h = __get_draw_rect(x, y, icon_w, icon_h, 1.5)
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
                draw_x, draw_y, draw_w, draw_h = __get_draw_rect(x, y, cfg.width, cfg.height, 1.5)
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

            if typeobject.fluidboxes then
                local recipe_typeobject = assert(iprototype.queryById(recipe))

                -- draw fluid icon of fluidboxes
                local t = {
                    {"ingredients", "input"},
                    {"results", "output"},
                }

                local begin_x, begin_y = __calc_begin_xy(x, y, iprototype.rotate_area(typeobject.area, DIRECTION[e.building.direction]))

                for _, r in ipairs(t) do
                    local i = 0
                    for idx, v in ipairs(irecipe.get_elements(recipe_typeobject[r[1]])) do
                        if iprototype.is_fluid_id(v.id) then
                            i = i + 1
                            local c = assert(typeobject.fluidboxes[r[2]][i])
                            local connection = assert(c.connections[1])
                            local connection_x, connection_y = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)

                            material_path = "/pkg/vaststars.resources/materials/fluid_icon_bg.material"
                            texture_x, texture_y, texture_w, texture_h = 0, 0, __get_texture_size(material_path)
                            draw_x, draw_y, draw_w, draw_h = __get_draw_rect(
                                begin_x + connection_x * iterrain.tile_size + iterrain.tile_size / 2,
                                begin_y - connection_y * iterrain.tile_size - iterrain.tile_size / 2,
                                texture_w,
                                texture_h,
                                1
                            )
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

                            local fluid_typeobject = iprototype.queryById(v.id)
                            local cfg = fluid_icon_canvas_cfg[fluid_typeobject.icon]
                            if not cfg then
                                assert(cfg, ("can not found `%s`"):format(fluid_typeobject.icon))
                                return
                            end
                            material_path = "/pkg/vaststars.resources/materials/fluid_icon_canvas.material"
                            texture_x, texture_y, texture_w, texture_h = cfg.x, cfg.y, cfg.width, cfg.height
                            draw_x, draw_y, draw_w, draw_h = __get_draw_rect(
                                begin_x + connection_x * iterrain.tile_size + iterrain.tile_size / 2,
                                begin_y - connection_y * iterrain.tile_size - iterrain.tile_size / 2,
                                texture_w,
                                texture_h,
                                1
                            )
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
            end -- typeobject.fluidboxes

        end
    end
end

local function create_icon(object_id, e, building_srt)
    local status = 0
    local recipe = 0
    local typeobject = iprototype.queryById(e.building.prototype)
    local is_generator = iprototype.has_type(typeobject.type, "generator")

    local function on_position_change(self, building_srt)
        local object = assert(objects:get(object_id))
        local e = assert(gameplay_core.get_entity(object.gameplay_eid))
        icanvas.remove_item(icanvas.types().ICON, object_id)
        __draw_icon(e, object_id, building_srt, status, recipe)
    end
    local function remove(self)
        icanvas.remove_item(icanvas.types().ICON, object_id)
    end
    local function update(self, e)
        local s
        if not is_generator and global.statistic.power and global.statistic.power[e.eid] and global.statistic.power[e.eid].power == 0 then
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
        object_id = object_id,
    }
end

local function __draw_consumer_icon(object_id, building_srt)
    local x, y = building_srt.t[1], building_srt.t[3]
    local material_path = "/pkg/vaststars.resources/materials/blackout.material"
    local icon_w, icon_h = __get_texture_size(material_path)
    local texture_x, texture_y, texture_w, texture_h = 0, 0, icon_w, icon_h
    local draw_x, draw_y, draw_w, draw_h = __get_draw_rect(x, y, icon_w, icon_h, 1.5)
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

local function create_consumer_icon(object_id, building_srt)
    __draw_consumer_icon(object_id, building_srt)
    local function remove()
        icanvas.remove_item(icanvas.types().ICON, object_id)
    end
    local function on_position_change(self, building_srt)
        icanvas.remove_item(icanvas.types().ICON, object_id)
        __draw_consumer_icon(object_id, building_srt)
    end
    return {
        on_position_change = on_position_change,
        remove = remove,
    }
end

local function update_motions()
    local time_step = 1.0 / 30
    local remove_idx = {}
    for index, mobj in ipairs(motions) do
        if not mobj.inited then
            mobj.inited = true
            local e <close> = w:entity(mobj.motion)
            ims.set_keyframes(e, {t = math3d.vector(mobj.from), step = 0.0}, {t = math3d.vector(mobj.to),  step = 1.0})
            -- ivs.set_state(e, "main_view", true) -- TODO
        end
        local e <close> = w:entity(mobj.motion)
        mobj.elapsed_time = mobj.elapsed_time + time_step
        local ratio = mobj.elapsed_time / mobj.duration
        if ratio > 1.0 then
            if mobj.repeat_count > 1 then
                mobj.repeat_count = mobj.repeat_count - 1
                mobj.elapsed_time = 0
                ims.set_ratio(e, 0)
            else
                ivs.set_state(e, "main_view", false)
                local cache = motion_caches[mobj.prefab]
                if not cache then
                    motion_caches[mobj.prefab] = {mobj}
                else
                    table.insert(cache, mobj)
                end
                remove_idx[#remove_idx + 1] = index
            end
        else
            ims.set_ratio(e, ratio)
        end
    end

    for _, value in ipairs(remove_idx) do
        -- table.remove(motions, value) -- TODO
    end
end

return function(world)
    -- update_motions()
    for e in world.ecs:select "assembling:in chest:in building:in capacitance?in eid:in" do
        -- object may not have been fully created yet
        local object = objects:coord(e.building.x, e.building.y)
        if not object then
            goto continue
        end

        local mat = math3d.ref(math3d.matrix {s = object.srt.s, r = ROTATORS[object.dir], t = object.srt.t})
        local building = global.buildings[object.id]

        if not building.io_shelves then
            if e.assembling.recipe ~= 0 then
                building.io_shelves = __create_io_shelves(object.id, world, e, mat)
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
                    building.io_shelves = __create_io_shelves(object.id, world, e, mat)
                else
                    building.io_shelves:update_heap_count(e, object.srt)
                end
            end
        end

        if not building.assembling_icon then
            building.assembling_icon = create_icon(object.id, e, object.srt)
        end
        building.assembling_icon:update(e)

        ::continue::
    end

    -- special handling for the display of the 'no power' icon on the laboratory
    for e in world.ecs:select "consumer:in assembling:absent building:in capacitance:in eid:in" do
        -- object may not have been fully created yet
        local object = objects:coord(e.building.x, e.building.y)
        if not object then
            goto continue
        end

        local building = global.buildings[object.id]

        if global.statistic.power and global.statistic.power[e.eid] and global.statistic.power[e.eid].power == 0 then
            if not building.consumer_icon then
                building.consumer_icon = create_consumer_icon(object.id, object.srt)
            end
        else
            if building.consumer_icon then
                building.consumer_icon:remove()
                building.consumer_icon = nil
            end
        end
        ::continue::
    end

    return false
end