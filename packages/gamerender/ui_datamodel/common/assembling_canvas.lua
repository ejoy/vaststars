local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iterrain = ecs.require "terrain"
local datalist = require "datalist"
local fs = require "filesystem"
local recipe_icon_canvas_cfg = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/recipe_icon_canvas.cfg")):read "a")
local fluid_icon_canvas_cfg = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/fluid_icon_canvas.cfg")):read "a")
local iprototype = require "gameplay.interface.prototype"
local ifluid = require "gameplay.interface.fluid"

local ICON_SIZE <const> = 64

local function _get_entity_canvas_center(position, w, h)
    return position[1] + ((w / 2 - 0.5) * iterrain.tile_size), position[3] - ((h / 2 - 0.5) * iterrain.tile_size) - iterrain.tile_size
end

local function get_assembling_canvas_items(object, x, y, w, h)
    local position = iterrain:get_begin_position_by_coord(x, y)
    if not position then
        return
    end
    local central_x, central_y = _get_entity_canvas_center(position, w, h)
    local t = {}

    if object.recipe == "" then
        local item_x, item_y = central_x, central_y
        t[#t + 1] ={
            texture = {
                path = "/pkg/vaststars.resources/ui/textures/assemble/setup2.texture",
                rect = {
                    x = 0,
                    y = 0,
                    w = ICON_SIZE,
                    h = ICON_SIZE,
                },
            },
            x = item_x, y = item_y, w = iterrain.tile_size, h = iterrain.tile_size,
            srt = {},
        }
        return t
    end

    local rate = iterrain.tile_size / 64
    local function _get_rect(x, y, icon_w, icon_h)
        local draw_w = icon_w * rate
        local draw_h = icon_h * rate
        local draw_x = x + (iterrain.tile_size - draw_w) / 2
        local draw_y = y + (iterrain.tile_size - draw_h) / 2

        return draw_x, draw_y, draw_w, draw_h
    end

    local recipe_typeobject = iprototype.queryByName("recipe", object.recipe)
    local cfg = recipe_icon_canvas_cfg[recipe_typeobject.icon]
    if not cfg then
        log.error(("can not found `%s`"):format(recipe_typeobject.icon))
        return
    end

    local item_x, item_y = position[1] + ((w / 2 - 0.5) * iterrain.tile_size), position[3] - ((h / 2 - 0.5) * iterrain.tile_size) - iterrain.tile_size
    local x, y, w, h = _get_rect(item_x, item_y, cfg.width, cfg.height)
    t[#t + 1] = {
        texture = {
            path = "/pkg/vaststars.resources/textures/recipe_icon_bg.texture",
            rect = { -- -- TODO: remove this hard code
                x = 0,
                y = 0,
                w = 90,
                h = 90,
            },
        },
        x = item_x, y = item_y, w = iterrain.tile_size, h = iterrain.tile_size,
        srt = {},
    }
    t[#t + 1] = {
        texture = {
            path = "/pkg/vaststars.resources/textures/recipe_icon_canvas.texture",
            rect = {
                x = cfg.x,
                y = cfg.y,
                w = cfg.width,
                h = cfg.height,
            },
        },
        x = x, y = y, w = w, h = h,
        srt = {},
    }

    -- draw fluid icon of fluidbox
    for _, fb in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) do
        if fb.fluid_name == "" then
            goto continue
        end

        local typeobject = iprototype.queryByName("fluid", fb.fluid_name)
        cfg = assert(fluid_icon_canvas_cfg[typeobject.icon], ("can not found `%s`"):format(typeobject.icon))
        position = iterrain:get_begin_position_by_coord(fb.x, fb.y)
        local x, y, w, h

        x, y, w, h = _get_rect(position[1], position[3] - iterrain.tile_size, ICON_SIZE, ICON_SIZE)
        t[#t + 1] = {
            texture = {
                path = "/pkg/vaststars.resources/textures/fluid_icon_bg.texture",
                rect = {
                    x = 0,
                    y = 0,
                    w = ICON_SIZE,
                    h = ICON_SIZE,
                },
            },
            x = x, y = y, w = w, h = h,
            srt = {},
        }

        x, y, w, h = _get_rect(position[1], position[3] - iterrain.tile_size, cfg.width, cfg.height)
        t[#t+1] = {
            texture = {
                path = "/pkg/vaststars.resources/textures/fluid_icon_canvas.texture",
                rect = {
                    x = cfg.x,
                    y = cfg.y,
                    w = cfg.width,
                    h = cfg.height,
                },
            },
            x = x, y = y, w = w, h = h,
            srt = {},
        }

        ::continue::
    end

    return t
end
return {
    get_assembling_canvas_items = get_assembling_canvas_items,
}