local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iterrain = ecs.require "terrain"
local datalist = require "datalist"
local fs = require "filesystem"
local fluid_icon_canvas_cfg = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/fluid_icon_canvas.cfg")):read "a")
local iprototype = require "gameplay.interface.prototype"

local function get_fluid_canvas_items(object, x, y, w, h)
    local position = iterrain:get_begin_position_by_coord(x, y)
    if not position then
        return
    end

    local t = {}

    local rate = iterrain.tile_size / 64
    local function _get_rect(x, y, icon_w, icon_h)
        local draw_w = icon_w * rate
        local draw_h = icon_h * rate
        local draw_x = x + (iterrain.tile_size - draw_w) / 2
        local draw_y = y + (iterrain.tile_size - draw_h) / 2

        return draw_x, draw_y, draw_w, draw_h
    end

    assert(object.fluid_name and object.fluid_name ~= "")
    local typeobject = iprototype.queryByName("fluid", object.fluid_name)
    local cfg = fluid_icon_canvas_cfg[typeobject.icon]
    if not cfg then
        assert(false)
        log.error(("can not found `%s`"):format(typeobject.icon))
        return
    end

    local item_x, item_y = position[1] + ((w / 2 - 0.5) * iterrain.tile_size), position[3] - ((h / 2 - 0.5) * iterrain.tile_size) - iterrain.tile_size
    local x, y, w, h = _get_rect(item_x, item_y, cfg.width, cfg.height)

    t[#t + 1] ={
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
    return t
end
return {
    get_fluid_canvas_items = get_fluid_canvas_items,
}