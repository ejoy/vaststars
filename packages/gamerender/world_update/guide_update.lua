local ecs = ...
local world = ecs.world
local global = require "global"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iguide = require "gameplay.interface.guide"
local irecipe = require "gameplay.interface.recipe"
local teardown_mb = world:sub {"teardown"}
local manual_add_mb = world:sub {"manual_add"}
local teardown_progress = 0
local manual_progress = 0
local function update_world(world)
    local science = global.science
    if iguide.has_task() and science.current_tech then
        local taskname = science.current_tech.name
        if taskname == "清除废墟" then
            for _, item_name in teardown_mb:unpack() do
                if item_name == "组装机残骸" or item_name == "排水口残骸" or item_name == "抽水泵残骸" then
                    teardown_progress = teardown_progress + 1
                    world:research_progress(taskname, teardown_progress)
                    if teardown_progress >= science.current_tech.detail.count then
                        iguide.set_task("none")
                    end
                end
            end
        elseif taskname == "手工生产3个铁齿轮" then
            for _, name, count in manual_add_mb:unpack() do
                if name == "铁齿轮" then
                    --local ingredients = irecipe.get_elements(science.current_tech.detail.ingredients)
                    manual_progress = manual_progress + count
                    world:research_progress(taskname, manual_progress)
                    if manual_progress >= science.current_tech.detail.count then
                        iguide.set_task("none")
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