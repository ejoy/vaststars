local ecs = ...
local world = ecs.world

local mc = import_package "ant.math".constant
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local math3d = require "math3d"
local COLOR_INVALID <const> = math3d.constant "null"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local iprototype = require "gameplay.interface.prototype"
local logistic_coord = ecs.require "terrain"
-- local PREFABS = {
--     "valid" = "prefabs/selected_box_valid.prefab",
--     "invalid" = "prefabs/selected_box_valid.prefab",
-- }

local mt = {}
mt.__index = mt

local SRTS = {
    -- lefttop
    {
        s = mc.ONE,
        r = math3d.constant( math3d.totable(math3d.quaternion({axis=mc.YAXIS, r=math.rad(180)}) )),
        t = math3d.constant("v4", {0, 0, 0}),
    },
    -- leftbottom
    {
        s = mc.ONE,
        r = math3d.constant( math3d.totable(math3d.quaternion({axis=mc.YAXIS, r=math.rad(90)}) )),
        t = math3d.constant("v4", {0, 0, -1}),
    },
    -- righttop
    {
        s = mc.ONE,
        r = math3d.constant( math3d.totable(math3d.quaternion({axis=mc.YAXIS, r=math.rad(270)}) )),
        t = math3d.constant("v4", {1, 0, 0}),
    },
    -- rightbottom
    {
        s = mc.ONE,
        r = math3d.constant( math3d.totable(math3d.quaternion({axis=mc.YAXIS, r=math.rad(0)}) )),
        t = math3d.constant("v4", {1, 0, -1}),
    },
}

function mt:remove()
    for _, v in ipairs(self.selected_boxes) do
        v:remove()
    end
end

function mt:set_srt(s, r, t)
    for idx, o in ipairs(self.selected_boxes) do
        local v = SRTS[idx]
        local nt = math3d.mul(math3d.vector {self.w * logistic_coord.tile_size, 0, self.h * logistic_coord.tile_size}, v.t)
        o:send("obj_motion", "set_srt", v.s, v.r, math3d.ref(math3d.add(t, nt)))
    end
end

function mt:set_state(state)

end

return function(srt, area, state)
    local w, h = iprototype.unpackarea(area)
    local M = {
        selected_boxes = {},
        w = w,
        h = h,
    }

    for _, v in ipairs(SRTS) do
        local nt = math3d.mul(math3d.vector {w * logistic_coord.tile_size, 0, h * logistic_coord.tile_size}, v.t)

        M.selected_boxes[#M.selected_boxes+1] = assert(igame_object.create({
            state = "opaque",
            color = COLOR_INVALID,
            prefab = "prefabs/selected_box_valid.prefab",
            group_id = 0,
            srt = {
                s = v.s,
                r = v.r,
                t = math3d.add(srt.t, nt),
            },
            render_layer = RENDER_LAYER.SELECTED_BOXES,
        }))
    end

    return setmetatable(M, mt)
end
