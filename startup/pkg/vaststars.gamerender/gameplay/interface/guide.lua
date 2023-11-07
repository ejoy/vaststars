local M = {}
local is_in_guide = false
local running = true
local globalGuide = {}

function M.init(gameplay_world, guide)
    globalGuide = guide
    M.world = gameplay_world
end

function M.get_guide_id()
    local world = M.world
    if not world then
        return
    end
    if not world.storage then
        world.storage = {guide_id = 1}
    end
    if not world.storage.guide_id then
        world.storage.guide_id = 1
    end
    return world.storage.guide_id
end

function M.get_guide()
    return globalGuide[M.get_guide_id()]
end

function M.get_progress()
    local guide_id = M.get_guide_id()
    if guide_id == 1 then
        return 0
    end
    assert(guide_id > 1 and guide_id <= #globalGuide + 1)
    return globalGuide[guide_id - 1].narrative_end.guide_progress
end

function M.step_progress()
    is_in_guide = false

    local storage = M.world.storage
    if storage.guide_id <= #globalGuide then
        storage.guide_id = storage.guide_id + 1
    end
end

function M.set_running(b)
    running = b
end

function M.is_running()
    return running
end

function M.set_is_in_guide(b)
    is_in_guide = b
end

function M.is_in_guide()
    return is_in_guide
end

function M.set_task(task_name)
    M.world.storage.guide_task = task_name
    M.world.storage.guide_progress = 0
end

function M.get_task_progress()
    return M.world.storage.guide_progress or 0
end

function M.has_task()
    return M.world and M.world.storage and M.world.storage.guide_task and M.world.storage.guide_task ~= "none"
end

return M