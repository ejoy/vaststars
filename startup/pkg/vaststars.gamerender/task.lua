local ecs = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"
local global = require "global"
local iconstant = require "gameplay.interface.constant"
local terrain = ecs.require "terrain"

local ALL_DIR = iconstant.ALL_DIR
local function _check_routemap(sx, sy, dx, dy, marked)
    marked = marked or {}
    assert(marked[sx << 16 | sy] == nil)
    marked[sx << 16 | sy] = true

    if sx == dx and sy == dy then
        return 1
    end

    local starting = global.roadnet[iprototype.packcoord(sx, sy)]
    local ending = global.roadnet[iprototype.packcoord(dx, dy)]
    if not starting or not ending then
        return 0
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

        local neighbor = global.roadnet[iprototype.packcoord(neighbor_x, neighbor_y)]
        if not neighbor then
            goto continue
        end

        if neighbor_x == dx and neighbor_y == dy then
            return 1
        end

        if _check_routemap(neighbor_x, neighbor_y, dx, dy, marked) then
            return 1
        end
        ::continue::
    end

    return 0
end

--[[
custom_type :
1. routemap, starting = {x, y}, ending = {x, y}
2. lorry_count, count = x,
3. set_recipe, recipe = x,
4. auto_complete_task,
5. set_item, item = x,
--]]
local custom_type_mapping = {
    [0] = {s = "undef", check = function() end}, -- TODO
    [1] = {s = "routemap", check = function(task_params) return _check_routemap(task_params.starting[1], task_params.starting[2], task_params.ending[1], task_params.ending[2]) end},
    [2] = {s = "lorry_count", check = function(task_params)
        local c = 0
        local gameplay_world = gameplay_core.get_world()
        for e in gameplay_world.ecs:select "station:in chest:in building:in" do
            -- TODO remove this
        end

        return c
    end, },
    [3] = {s = "set_recipe", check = function(task_params, recipe_name)
        if task_params.recipe == recipe_name then
            return 1
        else
            return 0
        end
    end, },
    [4] = {s = "auto_complete_task", check = function(task_params)
        return 1
    end, },
    [5] = {s = "set_item", check = function(task_params, item_name)
        if task_params.item == item_name then
            return 1
        else
            return 0
        end
    end, },
}

local mt = {}
function mt:__index(k)
    self[k] = {}
    return self[k]
end
local cache = setmetatable({}, mt)

local UNKNOWN <const> = 5 -- custom task type, see also register_unit("task", ...)
for _, typeobject in pairs(iprototype.each_maintype("task")) do
    local task_type, _, custom_type = string.unpack("<I2I2I2", typeobject.task) -- second param is multiple
    if task_type ~= UNKNOWN then
        goto continue
    end

    local c = custom_type_mapping[custom_type]
    assert(c, "unknown custom_type: " .. custom_type)
    cache[c.s][typeobject.name] = {task_name = typeobject.name, task_params = typeobject.task_params, check = c.check}
    ::continue::
end

local M = {}
function M.update_progress(custom_type_mapping, ...)
    local q = gameplay_core.get_world():research_queue()
    if #q == 0 then
        return
    end

    for _, v in ipairs(q) do
        local taskname = v
        local progress = gameplay_core.get_world():research_progress(taskname)
        local c = cache[custom_type_mapping][taskname]
        if not c then
            goto continue
        end

        local np = c.check(c.task_params, ...)
        if np ~= progress then
            local gwworld = gameplay_core.get_world()
            gwworld:research_progress(taskname, np)
        end
        ::continue::
    end
end
return M