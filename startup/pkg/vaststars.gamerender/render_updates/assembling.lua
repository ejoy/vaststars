local ecs = ...
local world = ecs.world
local w = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local FLUIDBOXES <const> = CONSTANT.FLUIDBOXES
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local ICON_STATUS_NOPOWER <const> = 1
local ICON_STATUS_NORECIPE <const> = 2
local ICON_STATUS_RECIPE <const> = 3
local ROTATORS <const> = {
    N = math.rad(0),
    E = math.rad(-90),
    S = math.rad(-180),
    W = math.rad(-270),
}

local aio = import_package "ant.io"
local datalist = require "datalist"
local function read_datalist(path)
    return datalist.parse(aio.readall(path))
end
local RECIPES_CFG <const> = read_datalist "/pkg/vaststars.resources/config/canvas/recipes.ant"

local assembling_sys = ecs.system "assembling_system"
local objects = require "objects"
local global = require "global"
local iprototype = require "gameplay.interface.prototype"
local create_io_shelves = ecs.require "render_updates.common.io_shelves".create
local assetmgr = import_package "ant.asset"
local icanvas = ecs.require "engine.canvas"
local irecipe = require "gameplay.interface.recipe"
local gameplay_core = require "gameplay.core"
local interval_call = ecs.require "engine.interval_call"
local draw_fluid_icon = ecs.require "fluid_icon"
local iprototype_cache = require "gameplay.prototype_cache.init"
local ifluid = require "gameplay.interface.fluid"
local ipower_check = ecs.require "power_check_system"
local gameplay = import_package "vaststars.gameplay"
local igameplay_chimney = gameplay.interface "chimney"
local ichest = require "gameplay.interface.chest"
local math3d = require "math3d"
local vsobject_manager = ecs.require "vsobject_manager"
local icoord = require "coord"
local iworld = require "gameplay.interface.world"
local igameplay_fluidbox = gameplay.interface "fluidbox"

local function __get_texture_size(materialpath)
    local res = assetmgr.resource(materialpath)
    local texobj = assetmgr.resource(res.properties.s_basecolor.texture)
    local ti = texobj.texinfo
    return tonumber(ti.width), tonumber(ti.height)
end

local function __get_draw_rect(x, y, icon_w, icon_h, multiple)
    multiple = multiple or 1
    local tile_size = TILE_SIZE * multiple
    y = y - tile_size
    local max = math.max(icon_h, icon_w)
    local draw_w = tile_size * (icon_w / max)
    local draw_h = tile_size * (icon_h / max)
    local draw_x = x - (tile_size / 2)
    local draw_y = y + (tile_size / 2)
    return draw_x, draw_y, draw_w, draw_h
end

local function __calc_begin_xy(x, y, w, h)
    local begin_x = x - (w * TILE_SIZE) / 2
    local begin_y = y + (h * TILE_SIZE) / 2
    return begin_x, begin_y
end

local function __draw_icon(e, object_id, building_srt, status, recipe)
    local x, y = math3d.index(building_srt.t, 1), math3d.index(building_srt.t, 3)
    if status == ICON_STATUS_NOPOWER then
        local material_path = "/pkg/vaststars.resources/materials/canvas/no-power.material"
        local icon_w, icon_h = __get_texture_size(material_path)
        local texture_x, texture_y, texture_w, texture_h = 0, 0, icon_w, icon_h
        local draw_x, draw_y, draw_w, draw_h = __get_draw_rect(x, y, icon_w, icon_h, 1.5)
        icanvas.add_item("icon",
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
    else
        local typeobject = iprototype.queryById(e.building.prototype)
        if status == ICON_STATUS_NORECIPE then
            local material_path = "/pkg/vaststars.resources/materials/canvas/no-recipe.material"
            local icon_w, icon_h = __get_texture_size(material_path)
            local texture_x, texture_y, texture_w, texture_h = 0, 0, icon_w, icon_h
            local draw_x, draw_y, draw_w, draw_h = __get_draw_rect(x, y, icon_w, icon_h, 1.5)
            icanvas.add_item("icon",
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
        else
            local material_path
            local icon_w, icon_h
            local draw_x, draw_y, draw_w, draw_h
            local texture_x, texture_y, texture_w, texture_h

            if typeobject.assembling_icon ~= false then
                local recipe_typeobject = assert(iprototype.queryById(recipe))
                local cfg = RECIPES_CFG[recipe_typeobject.recipe_icon]
                if not cfg then
                    error(("can not found `%s`"):format(recipe_typeobject.recipe_icon))
                    return
                end
                material_path = "/pkg/vaststars.resources/materials/canvas/recipes.material"
                texture_x, texture_y, texture_w, texture_h = cfg.x, cfg.y, cfg.width, cfg.height
                draw_x, draw_y, draw_w, draw_h = __get_draw_rect(x, y, cfg.width, cfg.height, 1.5)
                icanvas.add_item("icon",
                    object_id,
                    icanvas.get_key(material_path, RENDER_LAYER.ICON_CONTENT),
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

                local begin_x, begin_y = __calc_begin_xy(x, y, iprototype.rotate_area(typeobject.area, e.building.direction))
                for _, r in ipairs(t) do
                    local i = 0
                    for _, v in ipairs(irecipe.get_elements(recipe_typeobject[r[1]])) do
                        if iprototype.is_fluid_id(v.id) then
                            i = i + 1
                            local c = assert(typeobject.fluidboxes[r[2]][i])
                            local connection = assert(c.connections[1])
                            local connection_x, connection_y, connection_dir = iprototype.rotate_connection(connection.position, e.building.direction, typeobject.area)
                            draw_fluid_icon(
                                object_id,
                                begin_x + connection_x * TILE_SIZE + TILE_SIZE / 2,
                                begin_y - connection_y * TILE_SIZE - TILE_SIZE / 2,
                                v.id
                            )

                            local dx, dy = iprototype.move_coord(connection_x, connection_y, connection_dir, 1, 1)

                            if r[2] == "input" then
                                material_path = "/pkg/vaststars.resources/materials/canvas/fluid-indication-arrow-input.material"
                            else
                                material_path = "/pkg/vaststars.resources/materials/canvas/fluid-indication-arrow-output.material"
                            end

                            icon_w, icon_h = __get_texture_size(material_path)
                            texture_x, texture_y, texture_w, texture_h = 0, 0, icon_w, icon_h
                            draw_x, draw_y, draw_w, draw_h = __get_draw_rect(
                                begin_x + dx * TILE_SIZE + TILE_SIZE / 2,
                                begin_y - dy * TILE_SIZE - TILE_SIZE / 2,
                                icon_w,
                                icon_h
                            )
                            icanvas.add_item("icon",
                                object_id,
                                icanvas.get_key(material_path, RENDER_LAYER.FLUID_INDICATION_ARROW),
                                {
                                    texture = {
                                        rect = {
                                            x = texture_x,
                                            y = texture_y,
                                            w = texture_w,
                                            h = texture_h,
                                        },
                                        srt = {
                                            r = ROTATORS[connection_dir],
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
        icanvas.remove_item("icon", object_id)
        __draw_icon(e, object_id, building_srt, status, recipe)
    end
    local function remove(self)
        icanvas.remove_item("icon", object_id)
    end
    local function update(self, e)
        local s
        if not is_generator and not ipower_check.is_powered_on(gameplay_core.get_world(), e) then
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
        icanvas.remove_item("icon", object_id)
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
    local x, y = math3d.index(building_srt.t, 1), math3d.index(building_srt.t, 3)
    local material_path = "/pkg/vaststars.resources/materials/canvas/no-power.material"
    local icon_w, icon_h = __get_texture_size(material_path)
    local texture_x, texture_y, texture_w, texture_h = 0, 0, icon_w, icon_h
    local draw_x, draw_y, draw_w, draw_h = __get_draw_rect(x, y, icon_w, icon_h, 1.5)
    icanvas.add_item("icon",
        object_id,
        icanvas.get_key(material_path, RENDER_LAYER.ICON_CONTENT),
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
        icanvas.remove_item("icon", object_id)
    end
    local function on_position_change(self, building_srt)
        icanvas.remove_item("icon", object_id)
        __draw_consumer_icon(object_id, building_srt)
    end
    return {
        on_position_change = on_position_change,
        remove = remove,
    }
end

local function _find_neighbor_fluid(gameplay_world, x, y, dir, ground)
    local succ, dx, dy = false, x, y
    for i = 1, ground or 1 do
        succ, dx, dy = icoord.move(dx, dy, dir, 1)
        if not succ then
            return
        end

        local object = objects:coord(dx, dy)
        if object then
            local typeobject = iprototype.queryByName(object.prototype_name)
            if ground then
                if not iprototype.has_type(typeobject.type, "pipe_to_ground") then
                    goto continue
                end
            end

            local fluid_name
            if iprototype.has_type(typeobject.type, "fluidbox") then
                local e = assert(gameplay_world.entity[object.gameplay_eid])
                if e.fluidbox.fluid ~= 0 then
                    fluid_name = iprototype.queryById(e.fluidbox.fluid).name
                end
            elseif iprototype.has_type(typeobject.type, "fluidboxes") then
                fluid_name = {}
                local e = assert(gameplay_world.entity[object.gameplay_eid])
                for _, v in ipairs(FLUIDBOXES) do
                    local f = e.fluidboxes[v.fluid]
                    if f ~= 0 then
                        fluid_name[v.classify] = fluid_name[v.classify] or {}
                        fluid_name[v.classify][v.index] = iprototype.queryById(f).name
                    end
                end
            end
            for _, fb in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir, fluid_name)) do
                if fb.x == dx and fb.y == dy and fb.dir == iprototype.reverse_dir(dir) then
                    return fb.fluid_name, object
                end
            end

            goto continue
        end
        ::continue::
    end
end

function assembling_sys:gameworld_prebuild()
    local gameplay_world = gameplay_core.get_world()
    for e in gameplay_world.ecs:select "auto_set_recipe:in assembling:update building:in chest:update fluidboxes:update REMOVED:absent" do
        local object = assert(objects:coord(e.building.x, e.building.y))
        local typeobject = iprototype.queryById(e.building.prototype)
        local cache = iprototype_cache.get("recipe_config").assembling_recipes_2[typeobject.name]
        for _, fb in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir)) do
            local neighbor_fluid_name = _find_neighbor_fluid(gameplay_world, fb.x, fb.y, fb.dir)
            if neighbor_fluid_name then
                local recipe_name = cache[neighbor_fluid_name]
                if recipe_name then
                    local pt = iprototype.queryByName(recipe_name)
                    if pt.id ~= e.assembling.recipe then
                        iworld.set_recipe(gameplay_core.get_world(), e, recipe_name, typeobject.recipe_init_limit)
                    end
                    break
                end
            end
        end
    end

    for e in gameplay_world.ecs:select "auto_set_recipe:in chimney:update building:in fluidbox:update REMOVED:absent" do
        local object = assert(objects:coord(e.building.x, e.building.y))
        local typeobject = iprototype.queryById(e.building.prototype)
        local cache = iprototype_cache.get("recipe_config").chimney_recipes[typeobject.name]
        for _, fb in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir)) do
            local neighbor_fluid_name = _find_neighbor_fluid(gameplay_world, fb.x, fb.y, fb.dir)
            if neighbor_fluid_name then
                local recipe_name = cache[neighbor_fluid_name]
                if recipe_name then
                    local pt_recipe = iprototype.queryByName(recipe_name)
                    if pt_recipe.id ~= e.chimney.recipe then
                        igameplay_chimney.set_recipe(e, recipe_name)
                    end

                    local pt_fluid = iprototype.queryByName(neighbor_fluid_name)
                    if pt_fluid.id ~= e.fluidbox.fluid then
                        igameplay_fluidbox.update_fluidbox(gameplay_world, e, pt_fluid.id)
                    end
                    break
                end
            end
        end
    end
end

local function getGameObject(object)
    local vsobject = vsobject_manager:get(object.id) or error(("(%s) vsobject not found"):format(object.prototype_name))
    return vsobject.game_object
end

function assembling_sys:gameworld_build()
    local gameplay_world = gameplay_core.get_world()
    for e in gameplay_world.ecs:select "assembling:in building:in chest:in" do
        local object = objects:coord(e.building.x, e.building.y)
        if not object then
            goto continue
        end

        local typeobject = iprototype.queryById(e.building.prototype)
        if typeobject.io_shelf == false then
            goto continue
        end

        local building = global.buildings[object.id]

        --
        if e.assembling.recipe == 0 then
            local io_shelves = building.io_shelves
            if io_shelves then
                io_shelves:remove()
                building.io_shelves = nil
            end
        else
            local io_shelves = building.io_shelves
            if io_shelves then
                building.io_shelves:update(gameplay_world, e, getGameObject(object))
            else
                building.io_shelves = create_io_shelves(gameplay_world, e, getGameObject(object))
            end
        end
        ::continue::
    end
end

local update = interval_call(300, function()
    local gameplay_world = gameplay_core.get_world()

    for e in gameplay_world.ecs:select "assembling:in chest:in building:in capacitance?in eid:in" do
        -- object may not have been fully created yet
        local object = objects:coord(e.building.x, e.building.y)
        if not object then
            goto continue
        end

        local building = global.buildings[object.id]

        local io_shelves = building.io_shelves
        if io_shelves then
            local typeobject_recipe = iprototype.queryById(e.assembling.recipe)
            local ingredients_n <const> = #typeobject_recipe.ingredients//4 - 1
            local results_n <const> = #typeobject_recipe.results//4 - 1
            for idx = 1, ingredients_n + results_n do
                local slot = assert(ichest.get(gameplay_world, e.chest, idx))
                assert(slot.item ~= 0)
                local typeobject_item = iprototype.queryById(slot.item)
                if iprototype.has_type(typeobject_item.type, "item") then
                    io_shelves:update_item(idx, slot.amount)
                end
            end
        end

        if not building.assembling_icon then
            building.assembling_icon = create_icon(object.id, e, object.srt)
        end
        building.assembling_icon:update(e)
        ::continue::
    end

    -- special handling for the display of the 'no power' icon on the laboratory or airport
    for e in gameplay_world.ecs:select "consumer:in assembling:absent building:in capacitance:in eid:in" do
        -- object may not have been fully created yet
        local object = objects:coord(e.building.x, e.building.y)
        if not object then
            goto continue
        end

        local building = global.buildings[object.id]
        if not ipower_check.is_powered_on(gameplay_world, e) then
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
end)

function assembling_sys:gameworld_update()
    update()
end
