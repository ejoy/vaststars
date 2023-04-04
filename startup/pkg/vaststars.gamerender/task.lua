local ecs = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"

--[[
custom_type :
1. road_laying, count = x,
2. lorry_count, count = x,
3. set_recipe, recipe = x,
4. auto_complete_task,
5. set_item, item = x,
--]]
local custom_type_mapping = {
    [0] = {s = "undef", check = function() end}, -- TODO
    [1] = {s = "road_laying", check = function(task_params, count) return count end},
    [2] = {s = "lorry_count", check = function(task_params)
        return 0
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
for _, typeobject in pairs(iprototype.each_type("task")) do
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