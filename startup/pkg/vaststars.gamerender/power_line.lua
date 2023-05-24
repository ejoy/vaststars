local ecs   = ...
local world = ecs.world
local w     = world.w
local iterrain          = ecs.require "terrain"
local iline_entity      = ecs.require "engine.line_entity"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

local M ={}
local temp_lines
local lines
local pole_height = 30
local function get_line(pole1, pole2)
    if not pole1.power_network_link or not pole2.power_network_link then
        return
    end
    local pos1
    local pos2
    if pole1.position and pole1.smooth_pos then
        pos1 = {pole1.position[1], pole1.position[2], pole1.position[3]}
    end
    if pole2.position and pole2.smooth_pos then
        pos2 = {pole2.position[1], pole2.position[2], pole2.position[3]}
    end
    pos1 = pos1 or iterrain:get_position_by_coord(pole1.x, pole1.y, pole1.w, pole1.h)
    pos1[2] = pos1[2] + pole_height
    pos2 = pos2 or iterrain:get_position_by_coord(pole2.x, pole2.y, pole2.w, pole2.h)
    pos2[2] = pos2[2] + pole_height
    return pos1, pos2
    -- return iline_entity.create_lines({pos1, pos2}, 80, {1.0, 0.0, 0.0, 0.7}, RENDER_LAYER.WIRE)
end

function M.update_temp_line(temp_pole)
    if temp_lines then
        w:remove(temp_lines)
        temp_lines = nil
    end
    local lines_data = {}
    if temp_pole then
        for _, poles in pairs(temp_pole) do
            if poles.lines then
                for _, l in ipairs(poles.lines) do
                    local p0, p1 = get_line(l.p1, l.p2)
                    if p0 then
                        lines_data[#lines_data + 1] = p0
                        lines_data[#lines_data + 1] = p1
                    end
                end
            end
        end
    end
    if #lines_data > 0 then
        temp_lines = iline_entity.create_lines(lines_data, 80, {1.0, 0.0, 0.0, 0.7}, RENDER_LAYER.WIRE)
    end
end

function M.update_line(pole_lines)
    if lines then
        w:remove(lines)
        lines = nil
    end
    local lines_data = {}
    for _, l in ipairs(pole_lines) do
        local p0, p1 = get_line(l.p1, l.p2)
        if p0 then
            lines_data[#lines_data + 1] = p0
            lines_data[#lines_data + 1] = p1
        end
    end
    if #lines_data > 0 then
        lines = iline_entity.create_lines(lines_data, 80, {1.0, 0.0, 0.0, 0.7}, RENDER_LAYER.WIRE)
    end
end

return M