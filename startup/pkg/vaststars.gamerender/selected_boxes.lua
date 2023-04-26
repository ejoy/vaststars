local ecs = ...
local world = ecs.world
local w = world.w

local mc = import_package "ant.math".constant
local math3d = require "math3d"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local coord_system = ecs.require "terrain"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local irl = ecs.import.interface "ant.render|irender_layer"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local iani = ecs.import.interface "ant.animation|ianimation"

local function create_object(prefab, srt)
    local p = ecs.create_instance(prefab)
    function p:on_ready()
        local root <close> = w:entity(self.tag['*'][1])
        iom.set_srt(root, srt.s, srt.r, srt.t)

        for _, eid in ipairs(self.tag['*']) do
            local e <close> = w:entity(eid, "render_object?in animation_birth?in")
            if e.render_object then
                irl.set_layer(e, RENDER_LAYER.SELECTED_BOXES)
            end

            if e.animation_birth then
                iani.play(self, {name = e.animation_birth, loop = true, speed = 1.0, manual = false})
            end
        end
    end
    function p:on_message(name, ...)
        if name == "set_color" then
            local color = ...
            for _, eid in ipairs(self.tag['*']) do
                local e <close> = w:entity(eid, "material?in")
                if e.material then
                    imaterial.set_property(e, "u_emissive_factor", color)
                    imaterial.set_property(e, "u_basecolor_factor", color)
                end
            end
        elseif name == "obj_motion" then
            local method, s, r, t = ...
            local root <close> = w:entity(self.tag['*'][1])
            iom[method](root, s, r, t)
        end
    end
    return world:create_object(p)
end

local mt = {}
mt.__index = mt

local DIRECTION <const> = {
    math3d.constant("v4", {-1, 0, 1}),  -- lefttop
    math3d.constant("v4", {-1, 0, -1}), -- leftbottom
    math3d.constant("v4", {1, 0, 1}),   -- righttop
    math3d.constant("v4", {1, 0, -1}),  -- rightbottom
}

local ROTATION <const> = {
    math3d.constant( math3d.totable(math3d.quaternion({axis=mc.YAXIS, r=math.rad(180)}) )), -- lefttop
    math3d.constant( math3d.totable(math3d.quaternion({axis=mc.YAXIS, r=math.rad(90)})  )), -- leftbottom
    math3d.constant( math3d.totable(math3d.quaternion({axis=mc.YAXIS, r=math.rad(270)}) )), -- righttop
    math3d.constant( math3d.totable(math3d.quaternion({axis=mc.YAXIS, r=math.rad(0)})   )), -- rightbottom
}

function mt:remove()
    for _, v in ipairs(self.selected_boxes) do
        v:remove()
    end
end

function mt:set_position(center)
    self.center = center
    for idx, o in ipairs(self.selected_boxes) do
        local position = math3d.ref(math3d.muladd(DIRECTION[idx], math3d.vector(self.w, 0, self.h), self.center))
        o:send("obj_motion", "set_srt", mc.ONE, ROTATION[idx], math3d.ref(position))
    end
end

function mt:set_color(color)
    for _, o in ipairs(self.selected_boxes) do
        o:send("set_color", color)
    end
end

return function(prefab, center, color, w, h)
    local width = (w - 1) * coord_system.tile_size
    local height = (h - 1) * coord_system.tile_size

    local M = {
        selected_boxes = {},
        w = width / 2,
        h = height / 2,
        center = center,
    }

    for idx = 1, #DIRECTION do
        M.selected_boxes[idx] = create_object(prefab, {
            s = mc.ONE,
            r = ROTATION[idx],
            t = math3d.ref(math3d.muladd(DIRECTION[idx], math3d.vector(M.w, 0, M.h), M.center)),
        })
        if mc.NULL ~= color then
            M.selected_boxes[idx]:send("set_color", color)
        end
    end

    return setmetatable(M, mt)
end
