local ecs = ...
local global = require "global"
local iscience = require "gameplay.interface.science"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local function update_world(world, get_object_func)
    local science = global.science
    if science.current_tech then
        if world:is_researched(science.current_tech.name) then
            iscience.update_tech_list(world)
            iui.update("construct.rml", "update_tech")
            science.current_tech = nil
        end
    end
    local queue = world:research_queue()
    if #queue > 0 then
        if not science.current_tech then
            science.current_tech = science.tech_tree[queue[1]]
        end
        local progress = world:research_progress(queue[1])
        if progress then
            iui.update("construct.rml", "update_tech", science.current_tech, progress)
        end
    elseif science.current_tech then
        science.current_tech = nil
    end
end
return update_world