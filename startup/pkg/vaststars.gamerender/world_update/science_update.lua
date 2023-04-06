local ecs = ...
local world = ecs.world
local w = world.w

local global = require "global"
local iscience = require "gameplay.interface.science"
local iui = ecs.import.interface "vaststars.gamerender|iui"
return function(gameplay_world)
    local science = global.science
    if science.current_tech then
        if gameplay_world:is_researched(science.current_tech.name) then
            if science.current_tech.selected_tips then
                for _, tip in ipairs(science.current_tech.selected_tips) do
                    tip:remove()
                end
                science.current_tech.selected_tips = {}
            end
            iscience.update_tech_list(gameplay_world)
            iui.update("construct.rml", "update_tech")
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
            iui.update("construct.rml", "update_tech", science.current_tech)
        end
    elseif science.current_tech then
        science.current_tech = nil
    end
end