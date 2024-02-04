local ecs = ...
local world = ecs.world
local w = world.w

local RENDER_LAYER <const>  = ecs.require "engine.render_layer".RENDER_LAYER
local DELTA_TIME <const>    = require"gameplay.interface.constant".DELTA_TIME

local mc        = import_package "ant.math".constant

local math3d    = require "math3d"

local iom       = ecs.require "ant.objcontroller|obj_motion"
local irl       = ecs.require "ant.render|render_layer.render_layer"
local imaterial = ecs.require "ant.asset|material"
local iupdate   = ecs.require "update_system"

local function create_object(prefab, srt)
    return world:create_instance {
        prefab = prefab,
        on_ready = function (self)
            local root <close> = world:entity(self.tag['*'][1])
            iom.set_srt(root, srt.s, srt.r, srt.t)

            for _, eid in ipairs(self.tag['*']) do
                local e <close> = world:entity(eid, "render_object?in")
                if e.render_object then
                    irl.set_layer(e, RENDER_LAYER.SELECTED_BOXES)
                end
            end
        end,
        on_message = function (self, name, ...)
            if name == "set_color" then
                local color = ...
                for _, eid in ipairs(self.tag['*']) do
                    local e <close> = world:entity(eid, "material?in")
                    if e and e.material then
                        imaterial.set_property(e, "u_emissive_factor", color)
                        imaterial.set_property(e, "u_basecolor_factor", color)
                    end
                end
            elseif name == "obj_motion" then
                local method, s, r, t = ...
                local root <close> = world:entity(self.tag['*'][1])
                if root then
                    iom[method](root, s, r, t)
                end
            end
        end
    }
end

local mt = {}
mt.__index = mt

local CORNER_DIRECTIONS <const> = {
    math3d.constant("v4", {-1, 0, 1}),  -- left top
    math3d.constant("v4", {-1, 0,-1}), -- left bottom
    math3d.constant("v4", { 1, 0, 1}),   -- right top
    math3d.constant("v4", { 1, 0,-1}),  -- right bottom
}

local CORNER_QUATERNIONS <const> = {
    math3d.constant("quat", math3d.quaternion({axis=mc.YAXIS, r=math.rad(180)})), -- left top
    math3d.constant("quat", math3d.quaternion({axis=mc.YAXIS, r=math.rad(90)}) ), -- left bottom
    math3d.constant("quat", math3d.quaternion({axis=mc.YAXIS, r=math.rad(270)})), -- right top
    math3d.constant("quat", math3d.quaternion({axis=mc.YAXIS, r=math.rad(0)})  ), -- right bottom
}
local LINE_DIRECTIONS <const> = {
    mc.ZAXIS,
    mc.NZAXIS,
    mc.NXAXIS,
    mc.XAXIS,
}

local LINE_QUATERNIONS <const> = {
    math3d.constant("quat", math3d.quaternion({axis=mc.YAXIS, r=math.rad(0)}) ), -- top
    math3d.constant("quat", math3d.quaternion({axis=mc.YAXIS, r=math.rad(0)}) ), -- bottom
    math3d.constant("quat", math3d.quaternion({axis=mc.YAXIS, r=math.rad(90)})), -- left
    math3d.constant("quat", math3d.quaternion({axis=mc.YAXIS, r=math.rad(90)})), -- right
}

local LINE_SCALE <const> = {
    function(w, h) return math3d.vector((w-1)*2, 1, 1) end, -- top
    function(w, h) return math3d.vector((w-1)*2, 1, 1) end, -- bottom
    function(w, h) return math3d.vector((h-1)*2, 1, 1) end, -- left
    function(w, h) return math3d.vector((h-1)*2, 1, 1) end, -- right
}

local LINE_OFFSET <const> = {
    math3d.constant("v4", {0,  0, 3.8}), -- top
    math3d.constant("v4", {0,  0, 5}),   -- bottom
    math3d.constant("v4", {5,  0, 0}),   -- left
    math3d.constant("v4", {3.8,0, 0}),   -- right
}

local LINE_CHECK <const> = {
    function(w, h) return w - 1 > 0 end, -- top
    function(w, h) return w - 1 > 0 end, -- bottom
    function(w, h) return h - 1 > 0 end, -- left
    function(w, h) return h - 1 > 0 end, -- right
}

function mt:remove()
    for _, v in pairs(self.corners) do
        world:remove_instance(v)
    end
    for _, v in pairs(self.lines) do
        world:remove_instance(v)
    end
end

function mt:set_position(center)
    self.center.v = center
    for idx, o in pairs(self.corners) do
        local position = math3d.live(math3d.muladd(CORNER_DIRECTIONS[idx], self.corner_offset, self.center))
        world:instance_message(o, "obj_motion", "set_position", position)
    end
    for idx, o in pairs(self.lines) do
        local position = math3d.live(math3d.add(math3d.muladd(LINE_DIRECTIONS[idx], self.line_offset, self.center), LINE_OFFSET[idx]))
        world:instance_message(o, "obj_motion", "set_position", position)
    end
end

function mt:set_wh(w, h)
    if self.w == w and self.h == h then
        return
    end

    self.w = w
    self.h = h

    self:remove()

    local width = (w - 1) * 10
    local height = (h - 1) * 10
    self.corner_offset.v = math3d.vector(width / 2, 0, height / 2)
    self.line_offset.v = math3d.vector(w * 10 / 2, 0, h * 10 / 2)
    self.w = w
    self.h = h

    for idx = 1, #CORNER_DIRECTIONS do
        self.corners[idx] = create_object(self.prefabs[1], {
            s = mc.ONE,
            r = CORNER_QUATERNIONS[idx],
            t = math3d.live(math3d.muladd(CORNER_DIRECTIONS[idx], self.corner_offset, self.center)),
        })
        if mc.NULL ~= self.color then
            world:instance_message(self.corners[idx], "set_color", self.color)
        end
    end

    if self.prefabs[2] then
        for idx, f in ipairs(LINE_CHECK) do
            if f(w, h) then
                self.lines[idx] = create_object(self.prefabs[2], {
                    s = math3d.live(LINE_SCALE[idx](w, h)),
                    r = LINE_QUATERNIONS[idx],
                    t = math3d.live(math3d.add(math3d.muladd(LINE_DIRECTIONS[idx], self.line_offset, self.center), LINE_OFFSET[idx])),
                })
                if mc.NULL ~= self.color then
                    world:instance_message(self.lines[idx], "set_color", self.color)
                end
            end
        end
    end
end

function mt:set_color(color)
    self.color.v = math3d.vector(color)
    for _, o in pairs(self.corners) do
        world:instance_message(o, "set_color", math3d.live(color))
    end
    for _, o in pairs(self.lines) do
        world:instance_message(o, "set_color", math3d.live(color))
    end
end

function mt:set_color_transition(color, duration)
    if math3d.isequal(color, self.color) then
        return
    end

    local t = 0
    local from = self.color
    local to = color

    iupdate.add(function()
        t = t + DELTA_TIME
        self:set_color(math3d.lerp(from, to, t/duration))
        return t < duration
    end)
end

return function(prefabs, center, color, w, h)
    local width = (w - 1) * 10
    local height = (h - 1) * 10

    local M = {
        corners = {},
        corner_offset = math3d.ref(math3d.vector(width / 2, 0, height / 2)),
        line_offset = math3d.ref(math3d.vector(w * 10 / 2, 0, h * 10 / 2)),
        lines = {},
        center = math3d.ref(math3d.vector(center)),
        color = math3d.ref(color),
        prefabs = prefabs,
        w = w,
        h = h,
    }

    for idx = 1, #CORNER_DIRECTIONS do
        M.corners[idx] = create_object(prefabs[1], {
            s = mc.ONE,
            r = CORNER_QUATERNIONS[idx],
            t = math3d.live(math3d.muladd(CORNER_DIRECTIONS[idx], M.corner_offset, M.center)),
        })
        if mc.NULL ~= color then
            world:instance_message(M.corners[idx], "set_color", color)
        end
    end

    if prefabs[2] then
        for idx, f in ipairs(LINE_CHECK) do
            if f(w, h) then
                M.lines[idx] = create_object(prefabs[2], {
                    s = math3d.live(LINE_SCALE[idx](w, h)),
                    r = LINE_QUATERNIONS[idx],
                    t = math3d.live(math3d.add(math3d.muladd(LINE_DIRECTIONS[idx], M.line_offset, M.center), LINE_OFFSET[idx])),
                })
                if mc.NULL ~= color then
                    world:instance_message(M.lines[idx], "set_color", color)
                end
            end
        end
    end

    return setmetatable(M, mt)
end
