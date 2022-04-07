local ecs = ...
local world = ecs.world
local w = world.w

local gameplay = import_package "vaststars.gameplay"
import_package "vaststars.prototype"
local vector2 = ecs.require "common.vector2"

local M = {}

local funcs = {}
funcs["fluidbox"] = function(x, y, typeobject)
    local r = {}
    for _, conn in ipairs(typeobject.fluidbox.connections) do
        r[#r+1] = {x = x + conn.position[1], y = y + conn.position[2]}
    end
    return r
end

funcs["fluidboxes"] = function(x, y, typeobject)
    local r = {}
    for _, iotype in ipairs({"input", "output"}) do
        for _, v in ipairs(typeobject.fluidboxes[iotype]) do
            for _, conn in ipairs(v.connections) do
                r[#r+1] = {x = x + conn.position[1], y = y + conn.position[2]}
            end
        end
    end
    return r
end

local pipe_neighbor <const> = {
    vector2.DOWN,
    vector2.UP,
    vector2.LEFT,
    vector2.RIGHT,
    {0, 0},
}
function M.get_fluidbox_coord(prototype_name, x, y)
    local r = {}
    local typeobject = gameplay.queryByName("entity", prototype_name)
    if typeobject.pipe then
        for _, v in ipairs(pipe_neighbor) do
            r[#r+1] = {x + v[1], y + v[2]}
        end
        return r
    end

    local types = typeobject.type
    for i = 1, #types do
        local func = funcs[types[i]]
        if func then
            for _, v in ipairs(func(x, y, typeobject)) do
                r[#r + 1] = {v.x, v.y}
            end
        end
    end
    return r
end

return M