local global = require "global"
local guide = import_package "vaststars.prototype"("guide")
local M = {}
local running = false
local task = "none"
function M.get_guide_id(world)
    if not world.storage then
        world.storage = {guide_id = 1}
    end
    if not world.storage.guide_id then
        world.storage.guide_id = 1
    end
    return world.storage.guide_id
end

function M.get_guide(world)
    return guide[M.get_guide_id(world)]
end

function M.get_progress(world)
    local guide_id = M.get_guide_id(world)
    if guide_id < 2 then
        return 0
    end
    return guide[guide_id - 1].narrative_end.visible_value
end

function M.step_progress(world)
    running = false
    world.storage.guide_id = world.storage.guide_id + 1
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