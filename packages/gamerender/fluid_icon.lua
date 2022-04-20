local ecs   = ...
local world = ecs.world
local w     = world.w

local canvas = ecs.require "engine.canvas"
local terrain = ecs.require "terrain"

local M = {}

function M.create()
    canvas.create({0.0, 1.0, 0.0})
end

function M.add(name, x, y)
    local position = terrain.get_begin_position_by_coord(x, y)
    if not position then
        return
    end

    return canvas.add_items(name, position[1], position[3] - 10, 10, 10)
end

function M.remove(id)
    canvas.remove(id)
end

return M

