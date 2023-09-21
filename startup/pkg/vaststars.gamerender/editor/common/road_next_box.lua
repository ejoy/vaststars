local ecs = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local create_selected_boxes = ecs.require "selected_boxes"
local SPRITE_COLOR = import_package "vaststars.prototype"("sprite_color")
local math3d = require "math3d"
local terrain = ecs.require "terrain"
local ROAD_SIZE <const> = 2

local DIRECTION <const> = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
}
local DIR_MOVE_DELTA <const> = {
    ['N'] = {x = 0,  y = 1},
    ['E'] = {x = 1,  y = 0},
    ['S'] = {x = 0,  y = -1},
    ['W'] = {x = -1, y = 0},
    [DIRECTION.N] = {x = 0,  y = 1},
    [DIRECTION.E] = {x = 1,  y = 0},
    [DIRECTION.S] = {x = 0,  y = -1},
    [DIRECTION.W] = {x = -1, y = 0},
}

local mt = {}
mt.__index = mt

function mt:on_status_change(valid)
    local color = valid and SPRITE_COLOR.CONSTRUCT_OUTLINE_SELF_VALID or SPRITE_COLOR.CONSTRUCT_OUTLINE_SELF_INVALID
    self.selected_boxes:set_color_transition(color, 400)
end

function mt:on_position_change(building_srt)
    local position = building_srt.t
    local delta = DIR_MOVE_DELTA[self.forward_dir]
    local x, z = position[1] + delta.x * terrain.tile_size * ROAD_SIZE, position[3] + delta.y * terrain.tile_size * ROAD_SIZE
    self.selected_boxes:set_position(math3d.live(math3d.vector(x, position[2], z)))
end

function mt:remove()
    self.selected_boxes:remove()
end

function mt:set_forward_dir(dir)
    self.forward_dir = dir
end

return function (position, area, dir, valid, forward_dir)
    local self = setmetatable({}, mt)
    local color = valid and SPRITE_COLOR.CONSTRUCT_OUTLINE_SELF_VALID or SPRITE_COLOR.CONSTRUCT_OUTLINE_SELF_INVALID

    self.area = area
    self.forward_dir = forward_dir
    self.selected_boxes = create_selected_boxes(
        {
            "/pkg/vaststars.resources/glbs/selected-box-no-animation.glb|mesh.prefab",
            "/pkg/vaststars.resources/glbs/selected-box-no-animation-line.glb|mesh.prefab",
        },
        position, color, iprototype.rotate_area(area, dir)
    )
    return self
end
