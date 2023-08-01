local ecs, mailbox= ...
local world = ecs.world
local global = require "global"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iguide = require "gameplay.interface.guide"
local story_click_mb = mailbox:sub {"story_click"}
local gameplay_core = require "gameplay.core"

local M = {}
local guide_desc
function M:create(desc)
    guide_desc = desc
    local speech = desc.narrative
    return {
        speech = speech[1][1],
        avatar = speech[1][2],
        count = 1,
        total_count = #speech
    }
end

function M:stage_ui_update(datamodel)
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
            iui.close("ui/guide_pop.rml")

            local chapter_text = guide_desc.narrative_end.pop_chapter
            if chapter_text then
                iui.open({"ui/chapter_pop.rml"}, chapter_text)
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
                    world:pub {"focus_tips", "open", global.science.current_tech}
                end
                iguide.set_task(task_name)
            end
            iguide.step_progress()
            iui.set_guide_progress(iguide.get_progress())
        end
    end
end

return M