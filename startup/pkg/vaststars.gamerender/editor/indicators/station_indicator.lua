local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local iom = ecs.require "ant.objcontroller|obj_motion"
local irl = ecs.require "ant.render|render_layer.render_layer"
local imessage = ecs.require "message_sub"

local ARROW_VALID <const> = math3d.constant("v4", {0.0, 1.0, 0.0, 1})
local ARROW_INVALID <const> = math3d.constant("v4", {1.0, 0.0, 0.0, 1})
local mt = {}
mt.__index = mt

function mt:remove()
    world:remove_instance(self.arrow)
end

function mt:set_srt(s, r, t)
    imessage:pub("obj_motion", self.arrow, "set_srt", math3d.live(s), math3d.live(r), math3d.live(t))
end

function mt:set_state(state)
    local arrow_color
    if state == "valid" then
        arrow_color = ARROW_VALID
    else
        arrow_color = ARROW_INVALID
    end
    imessage:pub("material", self.arrow, "set_property", "u_basecolor_factor", arrow_color)
end

local function createPrefabInst(prefab, position)
    position = math3d.mark(position)

    return world:create_instance {
        prefab = prefab,
        on_ready = function (self)
            local root <close> = world:entity(self.tag['*'][1])

            math3d.unmark(position)
            iom.set_position(root, position)
            for _, eid in ipairs(self.tag['*']) do
                local e <close> = world:entity(eid, "render_object?in")
                if e.render_object then
                    irl.set_layer(e, RENDER_LAYER.ROAD_ENTRANCE_ARROW)
                end
            end
        end,
    }
end

return function(position, state)
    local arrow_color
    if state == "valid" then
        arrow_color = ARROW_VALID
    else
        arrow_color = ARROW_INVALID
    end

    local M = {}
    M.arrow = createPrefabInst("/pkg/vaststars.resources/glbs/road/station_indicator.glb|translucent.prefab", position)
    imessage:pub("material", M.arrow, "set_property", "u_basecolor_factor", arrow_color)

    return setmetatable(M, mt)
end
