local ecs   = ...
local world = ecs.world
local w     = world.w

local icas   = ecs.import.interface "ant.terrain|icanvas"
local iterrain = ecs.require "terrain"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local fs = require "filesystem"

local types <const> = {
    BUILDING_BASE = 1,
    -- Assembling recipe icon (displayed in the center of the assembling)
    -- Assembling liquid icon (displayed on the corresponding liquid port of the assembling)
    -- Fluid icon (displayed in the center of the pipe, shown every certain distance)
    ICON = 2,
    ROAD_ENTRANCE_MARKER = 3,
}

local cache = {} -- type = entity object of canavs

local entity_events = {}
entity_events.add_item = function(self, e, id, ...)
    self.cache = self.cache or {}
    self.cache[id] = self.cache[id] or {}

    for _, item_id in ipairs(icas.add_items(e, ...)) do
        self.cache[id][#self.cache[id]+1] = item_id
    end
end

entity_events.remove_item = function(self, e, id)
    if not self.cache or not self.cache[id] then
        return
    end

    for _, item_id in ipairs(self.cache[id]) do
        icas.remove_item(e, item_id)
    end
    self.cache[id] = nil
end
entity_events.show = function(_, e, b)
    icas.show(e, b)
end

local M = {}
function M.create(canvas_type, show, yaxis)
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
                t = {0.0, yaxis or iterrain.surface_height + 10, 0.0},
            },
            canvas = {
                textures = {},
                texts = {},
                show = show,
            },
        }
    }, entity_events)
end

function M.add_item(canvas_type, id, materialpath, ...)
	-- if not fs.exists(fs.path(materialpath)) then
    --     error("material not found: " .. materialpath)
    -- end

    local canvas_entity_object = assert(cache[canvas_type])
    canvas_entity_object:send("add_item", id, materialpath, ...)
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