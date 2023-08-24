local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local coord_system = require "global".coord_system
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local iom = ecs.require "ant.objcontroller|obj_motion"
local irl = ecs.require "ant.render|render_layer"

local ARROW_VALID <const> = math3d.constant("v4", {0.0, 1.0, 0.0, 1})
local ARROW_INVALID <const> = math3d.constant("v4", {1.0, 0.0, 0.0, 1})
local mt = {}
mt.__index = mt

function mt:remove()
    self.arrow:remove()
end

function mt:set_srt(s, r, t)
    self.arrow:send("obj_motion", "set_srt", s, r, t)
end

function mt:set_state(state)
    local arrow_color
    if state == "valid" then
        arrow_color = ARROW_VALID
    else
        arrow_color = ARROW_INVALID
    end
    self.arrow:send("material", "set_property", "u_basecolor_factor", arrow_color)
end

local imaterial = ecs.require "ant.asset|material"

local function createPrefabInst(prefab, position)
    prefab = assert(prefab:match("(.*%.glb|).*%.prefab"))
    prefab = prefab .. "translucent.prefab"

    local p = ecs.create_instance(prefab)
    function p:on_ready()
        local root <close> = world:entity(self.tag['*'][1])
        iom.set_position(root, math3d.vector(position))
        for _, eid in ipairs(self.tag['*']) do
            local e <close> = world:entity(eid, "render_object?in")
            if e.render_object then
                irl.set_layer(e, RENDER_LAYER.ROAD_ENTRANCE_ARROW)
            end
        end
    end
    function p:on_message(msg, method, ...)
        if msg == "obj_motion" then
            local root <close> = world:entity(self.tag['*'][1])
            iom[method](root, ...)
        end
        if msg == "material" then
            for _, eid in ipairs(self.tag["*"]) do
                local e <close> = world:entity(eid, "material?in")
                if e.material then
                    imaterial[method](e, ...)
                end
            end
        end
    end
    return world:create_object(p)
end

return function(srt, state)
    local arrow_color
    if state == "valid" then
        arrow_color = ARROW_VALID
    else
        arrow_color = ARROW_INVALID
    end

    local M = {}

    M.arrow = createPrefabInst("/pkg/vaststars.resources/glbs/road/station_indicator.glb|mesh.prefab", srt.t)
    M.arrow:send("material", "set_property", "u_basecolor_factor", arrow_color)

    return setmetatable(M, mt)
end
