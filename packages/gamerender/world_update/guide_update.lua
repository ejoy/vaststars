local ecs = ...
local world = ecs.world
local global = require "global"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iguide = require "gameplay.interface.guide"
local iprototype = require "gameplay.interface.prototype"
local objects = require "objects"
local iobject = ecs.require "object"
local teardown_mb = world:sub {"teardown"}
local manual_add_mb = world:sub {"manual_add"}
local task_progress
local fist_time = true
local function update_world(world)
    local science = global.science
    if iguide.has_task() and science.current_tech then
        if not task_progress then
            task_progress = iguide.get_task_progress()
        end
        local taskname = science.current_tech.name
        if taskname == "清除废墟" then
            if fist_time then
                for _, object in objects:all() do
                    local typename = object.prototype_name
                    if typename == "组装机残骸" or typename == "排水口残骸" or typename == "抽水泵残骸" then
                        object.state = "task"
                    end
                end
                iobject.flush()
                fist_time = false
            end
            for _, item_name in teardown_mb:unpack() do
                if item_name == "组装机残骸" or item_name == "排水口残骸" or item_name == "抽水泵残骸" then
                    task_progress = task_progress + 1
                    world:research_progress(taskname, task_progress)
                    if task_progress >= science.current_tech.detail.count then
                        iguide.set_task("none")
                        task_progress = 0
                    end
                end
            end
        elseif taskname == "手工生产3个铁齿轮" then
            for _, name, count in manual_add_mb:unpack() do
                local id = string.unpack("<I2", science.current_tech.detail.task, 5)
                local itemName = iprototype.queryById(id).name
                if name == itemName then
                    task_progress = task_progress + count
                    world:research_progress(taskname, task_progress)
                    if task_progress >= science.current_tech.detail.count then
                        iguide.set_task("none")
                        task_progress = 0
                    end
                end
            end
        end
    end
    if iguide.is_running() then
        return
    end
    local guide = iguide.get_guide()
    if not guide then
        return
    end
    local prerequisites = guide.prerequisites
    local run_guide = true
    if prerequisites then
        for _, value in ipairs(prerequisites) do
            if not world:is_researched(value) then
                run_guide = false
            end
        end
    end
    if run_guide then
        iui.open("guide_pop.rml", guide)
        iguide.set_running()
    end
end
return update_world