local global = require "global"
local guide = import_package "vaststars.prototype"("guide")
local M = {}
local running = false
local task = "none"
function M.get_guide_id()
    local world = M.world
    if not world.storage then
        world.storage = {guide_id = 1}
    end
    if not world.storage.guide_id then
        world.storage.guide_id = 1
    end
    return world.storage.guide_id
end

function M.get_guide()
    return guide[M.get_guide_id()]
end

function M.get_progress()
    local guide_id = M.get_guide_id()
    if guide_id < 2 then
        return 0
    end
    return guide[guide_id - 1].narrative_end.guide_progress
end

function M.step_progress()
    running = false
    local storage = M.world.storage
    storage.guide_id = storage.guide_id + 1
end

function M.set_running()
    running = true
end

function M.is_running()
    return running
end

function M.set_task(task_name)
    task = task_name
end

function M.has_task()
    return task ~= "none"
end

return M