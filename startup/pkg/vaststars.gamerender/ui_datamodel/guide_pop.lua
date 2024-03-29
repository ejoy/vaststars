local ecs, mailbox= ...
local world = ecs.world

local global = require "global"
local iui = ecs.require "engine.system.ui_system"
local iguide = require "gameplay.interface.guide"
local story_click_mb = mailbox:sub {"story_click"}
local gameplay_core = require "gameplay.core"
local iguide_tips = ecs.require "guide_tips"
local iRmlUi = ecs.require "ant.rmlui|rmlui_system"

local M = {}
local guide_desc
function M.create(desc)
    guide_desc = desc
    local speech = desc.narrative
    return {
        speech = speech[1][1],
        avatar = speech[1][2],
        count = 1,
    }
end

function M.update(datamodel)
    for _ in story_click_mb:unpack() do
        local speech = guide_desc.narrative
        local count = datamodel.count + 1
        if count <= #speech then
            datamodel.speech = speech[count][1]
            if speech[count][2] then
                datamodel.avatar = speech[count][2]
            end
            datamodel.count = count
        else
            iui.close("/pkg/vaststars.resources/ui/guide_pop.html")

            local pop_chapter = guide_desc.narrative_end.pop_chapter
            if pop_chapter then
                local url = pop_chapter[1]
                iRmlUi.open(url, url, pop_chapter[2])
            end
            local task = guide_desc.narrative_end.task
            local game_world = gameplay_core.get_world()
            if #task > 0 then
                local task_name = task[1]
                game_world:research_queue {task_name}
                local tech_node = global.science.tech_tree[task_name]
                if tech_node then
                    global.science.tech_picked_flag[tech_node.detail.name] = false
                    global.science.current_tech = tech_node
                    iguide_tips.show(global.science.current_tech)
                end
                iguide.set_task(task_name)
            end
            iguide.step_progress()
            iui.set_guide_progress(iguide.get_progress())
        end
    end
end

return M