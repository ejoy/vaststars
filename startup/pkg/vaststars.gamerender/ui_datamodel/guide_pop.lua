local ecs, mailbox= ...
local world = ecs.world
local w = world.w
local global = require "global"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iani = ecs.import.interface "ant.animation|ianimation"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local iguide = require "gameplay.interface.guide"
local story_click_mb = mailbox:sub {"story_click"}
local gameplay_core = require "gameplay.core"
local selected_boxes = ecs.require "selected_boxes"
local building_coord = require "global".building_coord_system
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

local function init_focus_tips(tech_node)
    local focus = tech_node.detail.guide_focus
    if not focus then
        return
    end
    for _, nd in ipairs(focus) do
        if nd.prefab then
            if not tech_node.selected_tips then
                tech_node.selected_tips = {}
            end
            local pos = building_coord:get_position_by_coord(nd.x, nd.y, nd.w, nd.h)
            local prefab = ecs.create_instance("/pkg/vaststars.resources/prefabs/arrow-guide.prefab")
            prefab.on_ready = function(inst)
                local children = inst.tag["*"]
                local re <close> = w:entity(children[1])
                iom.set_position(re, pos)
                for _, eid in ipairs(children) do
                    local e <close> = w:entity(eid, "animation_birth?in")
                    if e.animation_birth then
                        iani.play(eid, {name = e.animation_birth, loop = true})
                        break
                    end
                end
            end
            function prefab:on_message(msg) end
            function prefab:on_update() end
            world:create_object(prefab)
            tech_node.selected_tips[#tech_node.selected_tips + 1] = {selected_boxes(nd.prefab, building_coord:get_position_by_coord(nd.x, nd.y, 1, 1), nd.w, nd.h), prefab}
        else
            print("")
        end
    end
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
            local chapter_text = guide_desc.narrative_end.pop_chapter
            if chapter_text then
                iui.open({"chapter_pop.rml"}, chapter_text)
            end
            local task = guide_desc.narrative_end.task
            local game_world = gameplay_core.get_world()
            if #task > 0 then
                local task_name = task[1]
                game_world:research_queue {task_name}
                local tech_node = global.science.tech_tree[task_name]
                if tech_node then
                    init_focus_tips(tech_node)
                    global.science.tech_picked_flag[tech_node.detail.name] = false
                    global.science.current_tech = tech_node
                end
                iguide.set_task(task_name)
            end
            iguide.step_progress()
            iui.set_guide_progress(iguide.get_progress())
            log.info("story_click_mb update ui", iguide.get_progress()) -- TODO: remove this log
        end
    end
end

return M