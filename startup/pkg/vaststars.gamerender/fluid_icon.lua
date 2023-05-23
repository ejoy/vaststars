local ecs = ...
local world = ecs.world
local w = world.w

local assetmgr = import_package "ant.asset"
local iterrain = ecs.require "terrain"
local icanvas = ecs.require "engine.canvas"
local datalist = require "datalist"
local fs = require "filesystem"
local iprototype = require "gameplay.interface.prototype"

local FLUID_ICON_CANVAS_CFG <const> = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/fluid_icon_canvas.cfg")):read "a")
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local BG_MATERIAL_PATH = "/pkg/vaststars.resources/materials/fluid_icon_bg.material"
local ICON_MATERIAL_PATH = "/pkg/vaststars.resources/materials/fluid_icon_canvas.material"

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

local function __draw_bg(id, x, y, multiple)
    local icon_w, icon_h = __get_texture_size(BG_MATERIAL_PATH)
    local texture_x, texture_y, texture_w, texture_h = 0, 0, icon_w, icon_h
    local draw_x, draw_y, draw_w, draw_h = __get_draw_rect(x, y, icon_w, icon_h, multiple)
    icanvas.add_item(icanvas.types().ICON,
        id,
        BG_MATERIAL_PATH,
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

local function __draw_icon(id, x, y, fluid, multiple)
    local fluid_typeobject = iprototype.queryById(fluid)
    local cfg = FLUID_ICON_CANVAS_CFG[fluid_typeobject.icon]
    if not cfg then
        assert(cfg, ("can not found `%s`"):format(fluid_typeobject.icon))
        return
    end

    local texture_x, texture_y, texture_w, texture_h = cfg.x, cfg.y, cfg.width, cfg.height
    local draw_x, draw_y, draw_w, draw_h = __get_draw_rect(x, y, cfg.width, cfg.height, multiple)
    icanvas.add_item(icanvas.types().ICON,
        id,
        ICON_MATERIAL_PATH,
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

return function (id, x, y, fluid, multiple)
    multiple = multiple or 1

    __draw_bg(id, x, y, multiple)
    __draw_icon(id, x, y, fluid, multiple)
end
