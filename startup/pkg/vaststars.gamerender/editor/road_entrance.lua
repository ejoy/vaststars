local ecs = ...
local world = ecs.world

local math3d = require "math3d"
local iplant = ecs.require "engine.plane"
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local coord_system = require "global".coord_system

local ARROW_VALID <const> = math3d.constant("v4", {0.0, 1.0, 0.0, 1})
local ARROW_INVALID <const> = math3d.constant("v4", {1.0, 0.0, 0.0, 1})

local BLOCK_VALID <const> = math3d.constant("v4", {0.0, 2.5, 0.0, 0.5})
local BLOCK_INVALID <const> = math3d.constant("v4", {2.5, 0.0, 0.0, 0.5})

local BLOCK_SCALE = math3d.constant("v4", {coord_system.tile_unit_width * 1, 1, coord_system.tile_unit_height * 1, 0.0})

local mt = {}
mt.__index = mt

function mt:remove()
    self.arrow:remove()
    self.block:remove()
end

function mt:set_srt(s, r, t)
    self.arrow:send("obj_motion", "set_srt", s, r, t)
    self.block:send("obj_motion", "set_srt", BLOCK_SCALE, r, t)
end

function mt:set_state(state)
    local arrow_color, block_color
    if state == "valid" then
        arrow_color, block_color = ARROW_VALID, BLOCK_VALID
    else
        arrow_color, block_color = ARROW_INVALID, BLOCK_INVALID
    end
    self.arrow:update("prefabs/road/roadside_arrow.prefab", "translucent", arrow_color)
    self.block:send("material", "set_property", "u_basecolor_factor", block_color)
end

return function(srt, state)
    local arrow_color, block_color
    if state == "valid" then
        arrow_color, block_color = ARROW_VALID, BLOCK_VALID
    else
        arrow_color, block_color = ARROW_INVALID, BLOCK_INVALID
    end

    local M = {}
    M.arrow = assert(igame_object.create({
        state = "translucent",
        color = arrow_color,
        prefab = "prefabs/road/roadside_arrow.prefab",
        group_id = 0,
        srt = srt,
    }))

    local block_srt = {s = BLOCK_SCALE, r = srt.r, t = srt.t}
    M.block = iplant.create("/pkg/vaststars.resources/materials/translucent.material", "u_basecolor_factor", block_color, block_srt, "translucent")
    return setmetatable(M, mt)
end
