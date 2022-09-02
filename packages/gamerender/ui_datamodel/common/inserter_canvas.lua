local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iterrain = ecs.require "terrain"
local cfg <const> = {x = 0, y = 0, width = 32, height = 32}
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS

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
        srt = { r = ROTATORS[object.dir] },
    }
    return t
end

local selection_box_cfg <const> = {x = 0, y = 0, width = 128, height = 128}
local function get_selection_box(object, x, y, w, h)
    local position = iterrain:get_begin_position_by_coord(x, y)
    if not position then
        return
    end

    local t = {}

    local rate = iterrain.tile_size / selection_box_cfg.width -- rate of tile size
    local function _get_rect(x, y, icon_w, icon_h)
        local draw_w = icon_w * rate
        local draw_h = icon_h * rate
        local draw_x = x + (iterrain.tile_size - draw_w) / 2
        local draw_y = y + (iterrain.tile_size - draw_h) / 2

        return draw_x, draw_y, draw_w, draw_h
    end

    -- TODO: duplicate code?
    do
        local item_x, item_y = position[1], position[3] - iterrain.tile_size
        local x, y, w, h = _get_rect(item_x, item_y, selection_box_cfg.width, selection_box_cfg.height)
        t[#t + 1] ={
            texture = {
                path = "/pkg/vaststars.resources/ui/textures/common/selection-box.texture",
                rect = {
                    x = selection_box_cfg.x,
                    y = selection_box_cfg.y,
                    w = selection_box_cfg.width,
                    h = selection_box_cfg.height,
                },
            },
            x = x, y = y, w = w, h = h,
            srt = { r = ROTATORS.N },
        }
    end

    do
        local item_x, item_y = position[1] + (w - 1) * iterrain.tile_size, position[3] - iterrain.tile_size
        local x, y, w, h = _get_rect(item_x, item_y, selection_box_cfg.width, selection_box_cfg.height)
        t[#t + 1] ={
            texture = {
                path = "/pkg/vaststars.resources/ui/textures/common/selection-box.texture",
                rect = {
                    x = selection_box_cfg.x,
                    y = selection_box_cfg.y,
                    w = selection_box_cfg.width,
                    h = selection_box_cfg.height,
                },
            },
            x = x, y = y, w = w, h = h,
            srt = { r = ROTATORS.E },
        }
    end

    do
        local item_x, item_y = position[1], position[3] - (h - 1) * iterrain.tile_size - iterrain.tile_size
        local x, y, w, h = _get_rect(item_x, item_y, selection_box_cfg.width, selection_box_cfg.height)
        t[#t + 1] ={
            texture = {
                path = "/pkg/vaststars.resources/ui/textures/common/selection-box.texture",
                rect = {
                    x = selection_box_cfg.x,
                    y = selection_box_cfg.y,
                    w = selection_box_cfg.width,
                    h = selection_box_cfg.height,
                },
            },
            x = x, y = y, w = w, h = h,
            srt = { r = ROTATORS.W },
        }
    end

    do
        local item_x, item_y = position[1] + (w - 1) * iterrain.tile_size, position[3] - (h - 1) * iterrain.tile_size - iterrain.tile_size
        local x, y, w, h = _get_rect(item_x, item_y, selection_box_cfg.width, selection_box_cfg.height)
        t[#t + 1] ={
            texture = {
                path = "/pkg/vaststars.resources/ui/textures/common/selection-box.texture",
                rect = {
                    x = selection_box_cfg.x,
                    y = selection_box_cfg.y,
                    w = selection_box_cfg.width,
                    h = selection_box_cfg.height,
                },
            },
            x = x, y = y, w = w, h = h,
            srt = { r = ROTATORS.S },
        }
    end

    return t
end

return {
    get_items = get_items,
    get_selection_box = get_selection_box,
}