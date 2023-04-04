local ecs   = ...
local world = ecs.world
local w           = world.w
local iterrain          = ecs.require "terrain"
local iline_entity      = ecs.require "engine.line_entity"
local vsobject_manager  = ecs.require "vsobject_manager"
local math3d            = require "math3d"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

local M ={}
local temp_lines = {}
local lines = {}
local pole_height = 30
local function create_line(pole1, pole2)
    if not pole1.power_network_link or not pole2.power_network_link then
        return 0
    end
    local pos1
    local pos2
    if pole1.key and pole1.smooth_pos then
        local vsobject = assert(vsobject_manager:get(pole1.key))
        local p1 = math3d.totable(vsobject:get_position())
        pos1 = {p1[1], p1[2], p1[3]}
    end
    if pole2.key and pole2.smooth_pos then
        local vsobject = assert(vsobject_manager:get(pole2.key))
        local p2 = math3d.totable(vsobject:get_position())
        pos2 = {p2[1], p2[2], p2[3]}
    end
    pos1 = pos1 or iterrain:get_position_by_coord(pole1.x, pole1.y, pole1.w, pole1.h)
    pos1[2] = pos1[2] + pole_height
    pos2 = pos2 or iterrain:get_position_by_coord(pole2.x, pole2.y, pole2.w, pole2.h)
    pos2[2] = pos2[2] + pole_height
    return iline_entity.create_lines({pos1, pos2}, 80, {1.0, 0.0, 0.0, 0.7}, RENDER_LAYER.WIRE)
end

function M.clear_temp_line()
    for _, le in ipairs(temp_lines) do
        if le > 0 then
            w:remove(le)
        end
    end
    temp_lines = {}
end

function M.clear_line()
    M.clear_temp_line()
    for _, le in ipairs(lines) do
        if le > 0 then
            w:remove(le)
        end
    end
    lines = {}
end

function M.update_temp_line(temp_pole)
    M.clear_temp_line()
    if temp_pole then
        for _, poles in pairs(temp_pole) do
            if poles.lines then
                for _, l in ipairs(poles.lines) do
                    temp_lines[#temp_lines + 1] = create_line(l.p1, l.p2)
                end
            end
        end
    end
end

function M.update_line(pole_lines)
    M.clear_line()
    for _, l in ipairs(pole_lines) do
        lines[#lines + 1] = create_line(l.p1, l.p2)
    end
end

return M