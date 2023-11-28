local ecs = ...
local world = ecs.world
local w = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local TILE_SIZE <const> = CONSTANT.TILE_SIZE

local assetmgr = import_package "ant.asset"
local icanvas = ecs.require "engine.canvas"
local iprototype = require "gameplay.interface.prototype"

local aio = import_package "ant.io"
local datalist = require "datalist"
local function read_datalist(path)
    return datalist.parse(aio.readall(path))
end

local FLUIDS_CFG <const> = read_datalist "/pkg/vaststars.resources/config/canvas/fluids.cfg"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local BG_MATERIAL_PATH = "/pkg/vaststars.resources/materials/canvas/fluid-bg.material"
local ICON_MATERIAL_PATH = "/pkg/vaststars.resources/materials/canvas/fluids.material"

local function __get_texture_size(materialpath)
    local res = assetmgr.resource(materialpath)
    local texobj = assetmgr.resource(res.properties.s_basecolor.texture)
    local ti = texobj.texinfo
    return tonumber(ti.width), tonumber(ti.height)
end

local function __get_draw_rect(x, y, icon_w, icon_h, multiple)
    local tile_size = TILE_SIZE * multiple
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
    icanvas.add_item("icon",
        id,
        icanvas.get_key(BG_MATERIAL_PATH, RENDER_LAYER.ICON),
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
    local cfg = FLUIDS_CFG[fluid_typeobject.item_icon]
    if not cfg then
        error(("can not found `%s`"):format(fluid_typeobject.item_icon))
        return
    end

    local texture_x, texture_y, texture_w, texture_h = cfg.x, cfg.y, cfg.width, cfg.height
    local draw_x, draw_y, draw_w, draw_h = __get_draw_rect(x, y, cfg.width, cfg.height, multiple)
    icanvas.add_item("icon",
        id,
        icanvas.get_key(ICON_MATERIAL_PATH, RENDER_LAYER.ICON_CONTENT),
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
