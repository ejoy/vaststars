
local ecs = ...
local world = ecs.world

local CONSTANT = require "gameplay.interface.constant"
local ROTATORS = CONSTANT.ROTATORS
local MATERIAL <const> = "/pkg/vaststars.resources/materials/dotted_line.material"

local math3d = require "math3d"
local DELTA_VEC <const> = {
    ['N'] = math3d.constant("v4", {0, 0, -5}),
    ['E'] = math3d.constant("v4", {-5, 0, 0}),
    ['S'] = math3d.constant("v4", {0, 0, 5}),
    ['W'] = math3d.constant("v4", {5, 0, 0}),
}

local ientity = ecs.require "ant.entity|entity"

local M = {}
function M.create(position, quad_num, dir)
    local UNIT<const> = 10.0
    local ww = UNIT
    local eid = ientity.create_quad_entity(MATERIAL, {t=math3d.add(position, DELTA_VEC[dir]), r=ROTATORS[dir]}, {x=-0.5*ww, y=0, w=ww, h=UNIT*quad_num}, {x=0, y=0, w=1.0, h=quad_num})
    return {
        remove = function ()
            world:remove_entity(eid)
        end
    }
end
return M
