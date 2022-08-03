local ecs   = ...
local world = ecs.world
local w     = world.w

local icas   = ecs.import.interface "ant.terrain|icanvas"
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
entity_events.add_item = function(_, e, id, items)
    local canvas_entity = _get_canvas_entity()
    if not canvas_entity then
        return
    end

    cache_id[id] = icas.add_items(canvas_entity, items)
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

function M:add_item(id, items)
    assert(canvas_entity_object)
    canvas_entity_object:send("add_item", id, items)
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