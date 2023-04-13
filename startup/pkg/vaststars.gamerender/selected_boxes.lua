local ecs = ...
local world = ecs.world

local mc = import_package "ant.math".constant
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local math3d = require "math3d"
local COLOR_INVALID <const> = math3d.constant "null"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local logistic_coord = ecs.require "terrain"

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

function mt:set_position(t)
    for idx, o in ipairs(self.selected_boxes) do
        local t = math3d.add(self.center, math3d.mul(DIRECTION[idx], math3d.vector {self.w, 0, self.h} ))
        o:send("obj_motion", "set_srt", mc.ONE, ROTATION[idx], math3d.ref(t))
    end
end

return function(prefab, center, w, h)
    local width = (w - 1) * logistic_coord.tile_size
    local height = (h - 1) * logistic_coord.tile_size

    local M = {
        selected_boxes = {},
        w = width / 2,
        h = height / 2,
        center = center,
    }

    for idx = 1, #DIRECTION do
        M.selected_boxes[#M.selected_boxes+1] = assert(igame_object.create({
            state = "opaque",
            color = COLOR_INVALID,
            prefab = prefab,
            group_id = 0,
            srt = {
                s = mc.ONE,
                r = ROTATION[idx],
                t = math3d.add(M.center, math3d.mul(DIRECTION[idx], math3d.vector {M.w, 0, M.h} )),
            },
            render_layer = RENDER_LAYER.SELECTED_BOXES,
        }))
    end

    return setmetatable(M, mt)
end
