local ecs = ...
local world = ecs.world
local global = require "global"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iguide = require "gameplay.interface.guide"
local teardown_mb = world:sub {"teardown"}
local teardown_progress = 0
local function update_world(world)
    if iguide.has_task() then
        local science = global.science
        for _, item_name in teardown_mb:unpack() do
            if item_name == "组装机残骸" or item_name == "排水口残骸" or item_name == "抽水泵残骸" then
                teardown_progress = teardown_progress + 1
                world:research_progress(science.current_tech.name, teardown_progress)
            end
        end
        if teardown_progress == 3 then
            iguide.set_task("none")
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