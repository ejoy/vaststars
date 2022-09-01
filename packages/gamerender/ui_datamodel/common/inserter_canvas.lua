local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local mathpkg = import_package"ant.math"
local mc = mathpkg.constant
local iterrain = ecs.require "terrain"
local cfg <const> = {x = 0, y = 0, width = 32, height = 32}

local rotators <const> = {
    N = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(0)}),
    E = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(90)}),
    S = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(180)}),
    W = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(270)}),
}

local function get_items(object, x, y, w, h)
    local position = iterrain:get_begin_position_by_coord(x, y)
    if not position then
        return
    end

    local t = {}

    local rate = iterrain.tile_size / cfg.width -- rate of tile size
    local function _get_rect(x, y, icon_w, icon_h)
        local draw_w = icon_w * rate
        local draw_h = icon_h * rate
        local draw_x = x + (iterrain.tile_size - draw_w) / 2
        local draw_y = y + (iterrain.tile_size - draw_h) / 2

        return draw_x, draw_y, draw_w, draw_h
    end

    local item_x, item_y = position[1] + ((w / 2 - 0.5) * iterrain.tile_size), position[3] - ((h / 2 - 0.5) * iterrain.tile_size) - iterrain.tile_size
    local x, y, w, h = _get_rect(item_x, item_y, cfg.width, cfg.height)

    t[#t + 1] ={
        texture = {
            path = "/pkg/vaststars.resources/ui/textures/common/inserter-arrow.texture",
            rect = {
                x = cfg.x,
                y = cfg.y,
                w = cfg.width,
                h = cfg.height,
            },
        },
        x = x, y = y, w = w, h = h,
        srt = { r = rotators[object.dir] },
    }
    return t
end
return {
    get_items = get_items,
}