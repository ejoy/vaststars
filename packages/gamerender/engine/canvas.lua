local ecs   = ...
local world = ecs.world
local w     = world.w

local fs = require "filesystem"
local icas = ecs.import.interface "ant.terrain|icanvas"
local datalist = require "datalist"
local canvas_cfg = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/canvas.cfg")):read "a")

local function get_canvas_entity()
    local canvas_entity = w:singleton("canvas", "id:in canvas:in")
    if not canvas_entity then
        log.error("can not found canvas entity")
        return
    end
    return canvas_entity
end

local M = {}
function M.create(position)
    ecs.create_entity {
        policy = {
            "ant.scene|scene_object",
            "ant.terrain|canvas",
            "ant.general|name",
        },
        data = {
            name = "canvas",
            scene = {
                srt = {
                    t = position,
                }
            },
            canvas = {
                textures = {},
                texts = {},
            },
        }
    }
end

local cache_id = {}

function M.add_items(name, position_x, position_y, w, h, srt)
    local canvas_entity = get_canvas_entity()
    if not canvas_entity then
        return
    end

    local cfg = canvas_cfg[name]
    if not cfg then
        log.error(("can not found `%s`"):format(name))
        return
    end

    local item = {
        texture = {
            path = "/pkg/vaststars.resources/textures/canvas.texture",
            rect = {
                x = cfg.x,
                y = cfg.y,
                w = cfg.width,
                h = cfg.height,
            },
        },
        x = position_x, y = position_y, w = w, h = h,
        srt = srt,
    }

    local item_id = assert(icas.add_items(canvas_entity, item)[1])
    cache_id[item_id] = true
    return item_id
end

function M.remove_item(item_id)
    local canvas_entity = get_canvas_entity()
    if not canvas_entity then
        return
    end

    if not cache_id[item_id] then
        log.error(("can not found item id `%s`"):format(item_id))
        return
    end

    cache_id[item_id] = nil
    icas.remove_item(canvas_entity, item_id)
end
return M