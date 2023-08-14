local ecs   = ...
local world = ecs.world
local w     = world.w

local icas   = ecs.import.interface "ant.terrain|icanvas"
local iterrain = ecs.require "terrain"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local iom = ecs.require "ant.objcontroller|obj_motion"

local types <const> = {
    BUILDING_BASE = 1,
    ICON = 2,
    PICKUP_ICON = 3,
    ROAD_ENTRANCE_MARKER = 4,
}

local CANVAS_BUILD <const> = {
    [types.ICON] = {
        {
            render_layer = RENDER_LAYER.ICON,
            materials = {
                "/pkg/vaststars.resources/materials/canvas/no-power.material",
                "/pkg/vaststars.resources/materials/canvas/no-recipe.material",
                "/pkg/vaststars.resources/materials/canvas/fluid-bg.material",
            }
        },
        {
            render_layer = RENDER_LAYER.ICON_CONTENT,
            materials = {
                "/pkg/vaststars.resources/materials/canvas/recipes.material",
                "/pkg/vaststars.resources/materials/canvas/fluids.material",
                "/pkg/vaststars.resources/materials/canvas/no-power.material",
            }
        },
        {
            render_layer = RENDER_LAYER.FLUID_INDICATION_ARROW,
            materials = {
                "/pkg/vaststars.resources/materials/canvas/fluid-indication-arrow-input.material",
                "/pkg/vaststars.resources/materials/canvas/fluid-indication-arrow-output.material",
            }
        }
    },

    [types.PICKUP_ICON] = {
        {
            render_layer = RENDER_LAYER.ICON,
            materials = {
                "/pkg/vaststars.resources/materials/canvas/fluid-bg.material",
            }
        },
        {
            render_layer = RENDER_LAYER.ICON_CONTENT,
            materials = {
                "/pkg/vaststars.resources/materials/canvas/fluids.material",
                "/pkg/vaststars.resources/materials/canvas/no-power.material",
            }
        },
        {
            render_layer = RENDER_LAYER.FLUID_INDICATION_ARROW,
            materials = {
                "/pkg/vaststars.resources/materials/canvas/fluid-indication-arrow-input.material",
                "/pkg/vaststars.resources/materials/canvas/fluid-indication-arrow-output.material",
            }
        }
    },

    [types.BUILDING_BASE] = {
        {
            render_layer = RENDER_LAYER.BUILDING_BASE,
            materials = {
                "/pkg/vaststars.resources/materials/canvas/building-base.material",
            }
        },
    },

    [types.ROAD_ENTRANCE_MARKER] = {
        {
            render_layer = RENDER_LAYER.ROAD_ENTRANCE_ARROW,
            materials = {
                "/pkg/vaststars.resources/materials/canvas/road-entrance-marker.material",
            }
        },
    },
}

local mt = {}
mt.__index = function (t, k)
    t[k] = setmetatable({}, mt)
    return t[k]
end

local cache = setmetatable({}, mt) -- type = entity object of canavs
local key_cache = setmetatable({}, mt)

for _, infos in pairs(CANVAS_BUILD) do
    for _, info in ipairs(infos) do
        local render_layer = info.render_layer
        for _, materialpath in ipairs(info.materials) do
            key_cache[render_layer][materialpath] = ("%s|%s"):format(materialpath, render_layer)
        end
    end
end

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
entity_events.iom = function(_, e, method, ...)
    iom[method](e, ...)
end

local M = {}
function M.create(canvas_type, show, yaxis)
    assert(rawget(cache, canvas_type) == nil)
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
                show = show,
            },
            on_ready = function(e)
                local infos = CANVAS_BUILD[canvas_type]
                for _, info in ipairs(infos) do
                    icas.build(e, show, info.render_layer, table.unpack(info.materials))
                end
            end,
        }
    }, entity_events)
end

function M.add_item(canvas_type, id, key, ...)
    assert(type(key) == "string" )
    local canvas_entity_object = assert(cache[canvas_type])
    canvas_entity_object:send("add_item", id, key, ...)
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

function M.get_key(materialpath, render_layer)
    assert(rawget(key_cache[render_layer], materialpath))
    return key_cache[render_layer][materialpath]
end

function M.get(canvas_type)
    return cache[canvas_type]
end

function M.types()
    return types
end
return M