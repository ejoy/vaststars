local ecs   = ...
local world = ecs.world
local w     = world.w

local fs = require "filesystem"
local icas   = ecs.import.interface "ant.terrain|icanvas"
local datalist = require "datalist"
local canvas_cfg = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/canvas.cfg")):read "a")
local iterrain = ecs.require "terrain"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"

local function _get_canvas_entity()
    local canvas_entity = w:singleton("canvas", "id:in canvas:in")
    if not canvas_entity then
        log.error("can not found canvas entity")
        return
    end
    return canvas_entity
end

local cache_id = {}
local entity_events = {}
entity_events.add_item = function(_, e, id, name, x, y, w, h)
    local position = iterrain:get_begin_position_by_coord(x, y)
    if not position then
        return
    end

    local canvas_entity = _get_canvas_entity()
    if not canvas_entity then
        return
    end

    local cfg = canvas_cfg[name]
    if not cfg then
        log.error(("can not found `%s`"):format(name))
        return
    end

    local item_x, item_y = position[1] + ((w / 2 - 0.5) * iterrain.tile_size), position[3] - ((h / 2 - 0.5) * iterrain.tile_size) - iterrain.tile_size
    cache_id[id] = icas.add_items(canvas_entity,
        {
            texture = {
                path = "/pkg/vaststars.resources/textures/recipe_icon.texture",
                rect = { -- -- TODO: remove this hard code
                    x = 0,
                    y = 0,
                    w = 90,
                    h = 90,
                },
            },
            x = item_x, y = item_y, w = iterrain.tile_size, h = iterrain.tile_size,
            srt = {},
        },
        {
            texture = {
                path = "/pkg/vaststars.resources/textures/canvas.texture",
                rect = {
                    x = cfg.x,
                    y = cfg.y,
                    w = cfg.width,
                    h = cfg.height,
                },
            },
            x = item_x, y = item_y, w = iterrain.tile_size, h = iterrain.tile_size,
            srt = {},
    })
end

local M = {}
local canvas_entity_object
function M:create(show)
    canvas_entity_object = ientity_object.create(ecs.create_entity {
        policy = {
            "ant.scene|scene_object",
            "ant.terrain|canvas",
            "ant.general|name",
        },
        data = {
            name = "canvas",
            scene = {
                t = {0.0, iterrain.surface_height + 10, 0.0},
            },
            canvas = {
                textures = {},
                texts = {},
                show = show,
            },
        }
    }, entity_events)
end

function M:add_item(id, name, x, y, w, h) -- TODO: only support recipe icon now
    assert(canvas_entity_object)
    canvas_entity_object:send("add_item", id, name, x, y, w, h)
    return id
end

function M:remove_item(item_id)
    local canvas_entity = _get_canvas_entity()
    if not canvas_entity then
        return
    end

    if not cache_id[item_id] then
        log.error(("can not found item id `%s`"):format(item_id))
        return
    end

    for _, id in ipairs(cache_id[item_id]) do
        icas.remove_item(canvas_entity, id)
    end
    cache_id[item_id] = nil
end

function M:show(b)
    icas.show(b)
end
return M