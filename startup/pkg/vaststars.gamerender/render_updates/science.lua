local ecs = ...
local world = ecs.world
local w = world.w

local global = require "global"
local iscience = require "gameplay.interface.science"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local gameplay_core = require "gameplay.core"
local science_sys = ecs.system "science_system"

function science_sys:update_world()
    local gameplay_world = gameplay_core.get_world()
    local science = global.science
    if science.current_tech then
        if gameplay_world:is_researched(science.current_tech.name) then
            if science.current_tech.selected_tips then
                world:pub {"focus_tips", "close", science.current_tech}
            end
            iscience.update_tech_list(gameplay_world)
            iui.call_datamodel_method("construct.rml", "update_tech")
            world:pub {"research_finished", science.current_tech.name}
            science.current_tech = nil
            iui.open({"tech_tips.rml"}, {left = 170, top = 0.5})
        end
    end
    local queue = gameplay_world:research_queue()
    if #queue > 0 then
        if not science.current_tech then
            science.current_tech = science.tech_tree[queue[1]]
        end
        if science.current_tech then
            science.current_tech.progress = gameplay_world:research_progress(queue[1]) or 0
            iui.call_datamodel_method("construct.rml", "update_tech", science.current_tech)
        end
    elseif science.current_tech then
        science.current_tech = nil
    end
    return false
end