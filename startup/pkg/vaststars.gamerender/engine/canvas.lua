local ecs   = ...
local world = ecs.world
local w     = world.w

local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local CONSTANT <const> = require "gameplay.interface.constant"
local SURFACE_HEIGHT <const> = CONSTANT.SURFACE_HEIGHT

local icas   = ecs.require "ant.terrain|canvas"
local iom = ecs.require "ant.objcontroller|obj_motion"

local CANVAS_BUILD <const> = {
    ["icon"] = {
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

    ["pickup_icon"] = {
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

    ["road_entrance_marker"] = {
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

local M = {}
function M.create(canvas_type, show, yaxis)
    assert(rawget(cache, canvas_type) == nil)
    local materials = {}
    local canvas_eid; canvas_eid = world:create_entity {
        policy = {
            "ant.scene|scene_object",
            "ant.terrain|canvas",
        },
        data = {
            scene = {
                t = {0.0, yaxis or SURFACE_HEIGHT + 10, 0.0},
            },
            canvas = {
                show = show,
                materials = materials,
            },
            on_ready = function ()
                cache[canvas_type] = {
                    eid = canvas_eid,
                }
            end
        }
    }
    local infos = CANVAS_BUILD[canvas_type]
    for _, info in ipairs(infos) do
        icas.build(materials, canvas_eid, show, info.render_layer, table.unpack(info.materials))
    end
end

function M.add_item(canvas_type, id, key, ...)
    assert(type(key) == "string" )
    local canvas_entity_object = assert(cache[canvas_type])
    canvas_entity_object.cache = canvas_entity_object.cache or {}
    canvas_entity_object.cache[id] = canvas_entity_object.cache[id] or {}

    local e <close> = world:entity(canvas_entity_object.eid)
    for _, item_id in ipairs(icas.add_items(e, key, ...)) do
        canvas_entity_object.cache[id][#canvas_entity_object.cache[id]+1] = item_id
    end
    return id
end

function M.remove_item(canvas_type, id)
    local canvas_entity_object = assert(cache[canvas_type])
    if not canvas_entity_object.cache or not canvas_entity_object.cache[id] then
        return
    end
    local e <close> = world:entity(canvas_entity_object.eid)
    for _, item_id in ipairs(canvas_entity_object.cache[id]) do
        icas.remove_item(e, item_id)
    end
    canvas_entity_object.cache[id] = nil
end

function M.show(canvas_type, b)
    local canvas_entity_object = assert(cache[canvas_type])
    local e <close> = world:entity(canvas_entity_object.eid)
    icas.show(e, b)
end

function M.iom(canvas_type, method, ...)
    local canvas_entity_object = assert(cache[canvas_type])
    local e <close> = world:entity(canvas_entity_object.eid)
    iom[method](e, ...)
end

function M.get_key(materialpath, render_layer)
    assert(rawget(key_cache[render_layer], materialpath))
    return key_cache[render_layer][materialpath]
end
return M