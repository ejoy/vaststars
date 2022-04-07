local ecs = ...
local world = ecs.world
local w = world.w

local gameplay = import_package "vaststars.gameplay"
import_package "vaststars.prototype"
local general = require "gameplay.utility.general"
local rotate_fluidbox = general.rotate_fluidbox

local funcs = {}
funcs["fluidbox"] = function(typeobject, x, y, dir)
    local r = {}
    for _, conn in ipairs(typeobject.fluidbox.connections) do
        local dx, dy, dir = rotate_fluidbox(conn.position, dir, typeobject.area)
        r[#r+1] = {x = x + dx, y = y + dy, fluidbox_dir = {[dir] = true}}
    end
    return r
end

local iotypes <const> = {"input", "output"}
funcs["fluidboxes"] = function(typeobject, x, y, dir)
    local r = {}
    for _, iotype in ipairs(iotypes) do
        for _, v in ipairs(typeobject.fluidboxes[iotype]) do
            for _, conn in ipairs(v.connections) do
                local dx, dy, dir = rotate_fluidbox(conn.position, dir, typeobject.area)
                r[#r+1] = {x = x + dx, y = y + dy, fluidbox_dir = {[dir] = true}}
            end
        end
    end
    return r
end

local PIPE_FLUIDBOXES_DIR <const> = {'N', 'E', 'S', 'W'}
local function get_fluidboxes(prototype_name, x, y, dir)
    local r = {}
    local typeobject = gameplay.queryByName("entity", prototype_name)
    if typeobject.pipe then -- 管道直接认为有四个方向的流体口, 不读取配置
        local dir = {}
        for _, d in ipairs(PIPE_FLUIDBOXES_DIR) do
            dir[d] = true
        end
        r[#r+1] = {x = x, y = y, fluidbox_dir = dir}
    else
        local types = typeobject.type
        for i = 1, #types do
            local func = funcs[types[i]]
            if func then
                local t = func(typeobject, x, y, dir)
                table.move(t, 1, #t, #r + 1, r)
            end
        end
    end
    return r
end
return get_fluidboxes