local ecs, mailbox= ...
local world = ecs.world
local w = world.w
local global = require "global"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iani = ecs.import.interface "ant.animation|ianimation"
local ivs = ecs.import.interface "ant.scene|ivisible_state"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local iguide = require "gameplay.interface.guide"
local story_click_mb = mailbox:sub {"story_click"}
local gameplay_core = require "gameplay.core"
local selected_boxes = ecs.require "selected_boxes"
local building_coord = require "global".building_coord_system
local camera = ecs.require "engine.camera"
local focus_tips_event = world:sub {"focus_tips"}
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

local function open_focus_tips(tech_node)
    local focus = tech_node.detail.guide_focus
    if not focus then
        return
    end
    local width, height
    for _, nd in ipairs(focus) do
        if nd.prefab then
            if not width or not height then
                width, height = nd.w, nd.h
            end
            if not tech_node.selected_tips then
                tech_node.selected_tips = {}
            end
            
            local prefab
            if nd.show_arrow then
                local pos = building_coord:get_position_by_coord(nd.x, nd.y, nd.w, nd.h)
                prefab = ecs.create_instance("/pkg/vaststars.resources/prefabs/arrow-guide.prefab")
                prefab.on_ready = function(inst)
                    local children = inst.tag["*"]
                    local re <close> = w:entity(children[1])
                    iom.set_position(re, pos)
                    for _, eid in ipairs(children) do
                        local e <close> = w:entity(eid, "animation_birth?in visible_state?in")
                        if e.animation_birth then
                            iani.play(eid, {name = e.animation_birth, loop = true})
                        elseif e.visible_state then
                            ivs.set_state(e, "cast_shadow", false)
                        end
                    end
                end
                function prefab:on_message(msg) end
                function prefab:on_update() end
                world:create_object(prefab)
            end
            tech_node.selected_tips[#tech_node.selected_tips + 1] = {selected_boxes(nd.prefab, building_coord:get_position_by_coord(nd.x, nd.y, 1, 1), nd.w, nd.h), prefab}
        elseif nd.camera_x and nd.camera_y then
            camera.focus_on_position(building_coord:get_position_by_coord(nd.camera_x, nd.camera_y, width, height))
        end
    end
end

local function close_focus_tips(tech_node)
    local selected_tips = tech_node.selected_tips
    if not selected_tips then
        return
    end
    for _, tip in ipairs(selected_tips) do
        tip[1]:remove()
        if tip[2] then
            local children = tip[2].tag["*"]
            for _, eid in ipairs(children) do
               w:remove(eid)
            end
        end
    end
    tech_node.selected_tips = {}
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

function M:stage_camera_usage(datamodel)
    for _, action, tech_node in focus_tips_event:unpack() do
        if action == "open" then
            open_focus_tips(tech_node)
        elseif action == "close" then
            close_focus_tips(tech_node)
        end
    end
    
end

return M