local ecs = ...
local world = ecs.world
local w = world.w

local global = require "global"
local iscience = require "gameplay.interface.science"
local iui = ecs.require "engine.system.ui_system"
local gameplay_core = require "gameplay.core"
local science_sys = ecs.system "science_system"
local iguide_tips = ecs.require "guide_tips"

function science_sys:gameworld_update()
    local gameplay_world = gameplay_core.get_world()
    local science = global.science
    if science.current_tech then
        if gameplay_world:is_researched(science.current_tech.name) then
            iguide_tips.clear()
            iscience.update_tech_list(gameplay_world, science.current_tech)
            world:pub {"tech_recipe_unpicked_dirty"}
            iui.call_datamodel_method("/pkg/vaststars.resources/ui/construct.html", "update_tech")
            world:pub {"research_finished", science.current_tech.name}
            science.current_tech = nil
            iui.open({rml = "/pkg/vaststars.resources/ui/tech_tips.html"}, {left = '170vmin', top = '0.5vmin'})
        end
    end
    local queue = gameplay_world:research_queue()
    if #queue > 0 then
        if not science.current_tech then
            local tech_name = queue[1]
            -- TODO: fix bug: gameplay_world:research_queue() will return finished tech
            if not gameplay_world:is_researched(tech_name) then
                science.current_tech = science.tech_tree[tech_name]
            end
        else
            science.current_tech.progress = gameplay_world:research_progress(queue[1]) or 0
            iui.call_datamodel_method("/pkg/vaststars.resources/ui/construct.html", "update_tech", science.current_tech)
        end
    elseif science.current_tech then
        science.current_tech = nil
    end
    return false
end

function science_sys:exit()
    local science = global.science
    science.current_tech = nil
end