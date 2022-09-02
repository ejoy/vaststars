local ecs   = ...
local world = ecs.world
local w     = world.w

local icas   = ecs.import.interface "ant.terrain|icanvas"
local iterrain = ecs.require "terrain"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"

local types <const> = {
    RECIPE = 1,
}

local cache = {} -- type = entity object of canavs

local entity_events = {}
entity_events.add_item = function(self, e, id, items)
    self.cache = self.cache or {}
    self.cache[id] = icas.add_items(e, items)
end
entity_events.remove_item = function(self, e, id)
    for _, item_id in ipairs(self.cache[id]) do
        icas.remove_item(e, item_id)
    end
    self.cache[id] = nil
end
entity_events.show = function(_, e, b)
    icas.show(e, b)
end

local M = {}
function M.create(canvas_type, show)
    assert(cache[canvas_type] == nil)
    cache[canvas_type] = ientity_object.create(ecs.create_entity {
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

function M.add_item(canvas_type, id, items)
    local canvas_entity_object = assert(cache[canvas_type])
    canvas_entity_object:send("add_item", id, items)
    return id
end

function M.remove_item(canvas_type, id)
    local canvas_entity_object = assert(cache[canvas_type])
    canvas_entity_object:send("remove_item", id)
end

function M.show(canvas_type, b)
    local canvas_entity_object = assert(cache[canvas_type])
    canvas_entity_object:send("show", b)
end

function M.types()
    return types
end
return M