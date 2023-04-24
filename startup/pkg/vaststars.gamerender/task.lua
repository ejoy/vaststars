local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local iprototype_cache = require "gameplay.prototype_cache.init"

local M = {}
function M.update_progress(custom_type_mapping, ...)
    local q = gameplay_core.get_world():research_queue()
    if #q == 0 then
        return
    end

    for _, v in ipairs(q) do
        local taskname = v
        local progress = gameplay_core.get_world():research_progress(taskname)
        local c = iprototype_cache.get("task")[custom_type_mapping][taskname]
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