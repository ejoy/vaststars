local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iterrain = ecs.require "terrain"
local datalist = require "datalist"
local assetmgr  = import_package "ant.asset"
local fs = require "filesystem"
local recipe_icon_canvas_cfg = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/recipe_icon_canvas.cfg")):read "a")
local fluid_icon_canvas_cfg = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/fluid_icon_canvas.cfg")):read "a")
local iprototype = require "gameplay.interface.prototype"
local ifluid = require "gameplay.interface.fluid"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

local function _get_entity_canvas_center(position, w, h)
    return position[1] + ((w / 2 - 0.5) * iterrain.tile_size), position[3] - ((h / 2 - 0.5) * iterrain.tile_size) - iterrain.tile_size
end

local function _get_texture_size(materialpath)
    local res = assetmgr.resource(materialpath)
    local texobj = assetmgr.resource(res.properties.s_basecolor.texture)
    local ti = texobj.texinfo
    return ti.width, ti.height
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
        local material_path = "/pkg/vaststars.resources/materials/setup2.material"
        local icon_w, icon_h = _get_texture_size(material_path)
        t[#t+1] = {
            material_path,
            RENDER_LAYER.ICON,
            {
                texture = {
                    rect = {
                        x = 0,
                        y = 0,
                        w = icon_w,
                        h = icon_h,
                    },
                },
                x = item_x, y = item_y, w = iterrain.tile_size, h = iterrain.tile_size,
            }
        }
        return t
    end

    local function _get_rect(x, y, icon_w, icon_h)
        local max = math.max(icon_h, icon_w)
        local draw_w = iterrain.tile_size * (icon_w / max)
        local draw_h = iterrain.tile_size * (icon_h / max)
        local draw_x = x + (iterrain.tile_size - draw_w) / 2
        local draw_y = y + (iterrain.tile_size - draw_h) / 2
        return draw_x, draw_y, draw_w, draw_h
    end

    local recipe_typeobject = iprototype.queryByName(object.recipe)
    local cfg = recipe_icon_canvas_cfg[recipe_typeobject.recipe_icon]
    if not cfg then
        assert(cfg)
        log.error(("can not found `%s`"):format(recipe_typeobject.recipe_icon))
        return
    end

    local draw_x, draw_y, draw_w, draw_h
    local item_x, item_y = position[1] + ((w / 2 - 0.5) * iterrain.tile_size), position[3] - ((h / 2 - 0.5) * iterrain.tile_size) - iterrain.tile_size

    local material_path = "/pkg/vaststars.resources/materials/recipe_icon_bg.material"
    local icon_w, icon_h = _get_texture_size(material_path)
    draw_x, draw_y, draw_w, draw_h = _get_rect(item_x, item_y, icon_w, icon_h)
    t[#t + 1] = {
        material_path,
        RENDER_LAYER.ICON,
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
    }

    draw_x, draw_y, draw_w, draw_h = _get_rect(item_x, item_y, cfg.width, cfg.height)
    t[#t + 1] = {
        "/pkg/vaststars.resources/materials/recipe_icon_canvas.material",
        RENDER_LAYER.ICON_CONTENT,
        {
            texture = {
                rect = {
                    x = cfg.x,
                    y = cfg.y,
                    w = cfg.width,
                    h = cfg.height,
                },
            },
            x = draw_x, y = draw_y, w = draw_w, h = draw_h,
        }
    }

    -- draw fluid icon of fluidbox
    local bg, icon = {}, {}
    for _, fb in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) do
        if fb.fluid_name == "" then
            goto continue
        end

        local typeobject = iprototype.queryByName(fb.fluid_name)
        cfg = assert(fluid_icon_canvas_cfg[typeobject.icon], ("can not found `%s`"):format(typeobject.icon))
        position = iterrain:get_begin_position_by_coord(fb.x, fb.y)
        local x, y, w, h
        local icon_w, icon_h = _get_texture_size("/pkg/vaststars.resources/materials/fluid_icon_bg.material")

        x, y, w, h = _get_rect(position[1], position[3] - iterrain.tile_size, icon_w, icon_h)
        bg[#bg + 1] = {
            texture = {
                rect = {
                    x = 0,
                    y = 0,
                    w = icon_w,
                    h = icon_h,
                },
            },
            x = x, y = y, w = w, h = h,
            srt = {},
        }

        x, y, w, h = _get_rect(position[1], position[3] - iterrain.tile_size, cfg.width, cfg.height)
        icon[#icon+1] = {
            texture = {
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

    if next(bg) then
        t[#t + 1] = {
            "/pkg/vaststars.resources/materials/fluid_icon_bg.material",
            RENDER_LAYER.ICON,
            table.unpack(bg)
        }
    end

    if next(icon) then
        t[#t + 1] = {
            "/pkg/vaststars.resources/materials/fluid_icon_canvas.material",
            RENDER_LAYER.ICON_CONTENT,
            table.unpack(icon)
        }
    end

    return t
end
return {
    get_assembling_canvas_items = get_assembling_canvas_items,
}