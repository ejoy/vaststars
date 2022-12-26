local ecs = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"
local global = require "global"
local iconstant = require "gameplay.interface.constant"
local terrain = ecs.require "terrain"
local iroadnet = ecs.require "roadnet"

local ALL_DIR = iconstant.ALL_DIR
local function _check_routemap(sx, sy, dx, dy, marked)
    marked = marked or {}
    assert(marked[sx << 16 | sy] == nil)
    marked[sx << 16 | sy] = true

    if sx == dx and sy == dy then
        return true
    end

    local starting = iroadnet.editor_get(sx, sy)
    local ending = iroadnet.editor_get(dx, dy)
    if not starting or not ending then
        return false
    end

    local succ, neighbor_x, neighbor_y
    for _, neighbor_dir in ipairs(ALL_DIR) do
        succ, neighbor_x, neighbor_y = terrain:move_coord(sx, sy, neighbor_dir, 1)
        if not succ then
            goto continue
        end

        if marked[neighbor_x << 16 | neighbor_y] then
            goto continue
        end

        local neighbor = iroadnet.editor_get(neighbor_x, neighbor_y)
        if not neighbor then
            goto continue
        end

        if neighbor_x == dx and neighbor_y == dy then
            return true
        end

        if _check_routemap(neighbor_x, neighbor_y, dx, dy, marked) then
            return true
        end
        ::continue::
    end

    return false
end

--[[
custom_type :
1. routemap, starting = {x, y}, ending = {x, y}
--]]
local custom_type_mapping = {
    [0] = {s = "undef", check = function() end}, -- TODO
    [1] = {s = "routemap", check = function(task_params) return _check_routemap(task_params.starting[1], task_params.starting[2], task_params.ending[1], task_params.ending[2]) end},
}

local mt = {}
function mt:__index(k)
    self[k] = {}
    return self[k]
end
local cache = setmetatable({}, mt)

local UNKNOWN <const> = 5 -- custom task type, see also register_unit("task", ...)
for _, typeobject in pairs(iprototype.each_maintype("tech", "task")) do
    local task_type, custom_type = string.unpack("<I2I2", typeobject.task)
    if task_type ~= UNKNOWN then
        goto continue
    end

    local c = custom_type_mapping[custom_type]
    assert(c, "unknown custom_type: " .. custom_type)
    cache[c.s][typeobject.name] = {task_name = typeobject.name, task_params = typeobject.task_params, check = c.check}
    ::continue::
end

local M = {}
function M.update_progress(custom_type_mapping)
    local science = global.science
    if not science.current_tech then
        return
    end

    local taskname = science.current_tech.name
    local progress = science.current_tech.progress
    local c = cache[custom_type_mapping][taskname]
    if not c then
        return
    end

    if c.check(c.task_params) then
        local gwworld = gameplay_core.get_world()
        gwworld:research_progress(taskname, progress + 1)
    end
end
return M