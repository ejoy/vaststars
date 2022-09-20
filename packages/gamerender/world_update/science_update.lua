local ecs = ...
local w = ecs.world
local global = require "global"
local iscience = require "gameplay.interface.science"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local function update_world(world, get_object_func)
    local science = global.science
    if science.current_tech then
        if world:is_researched(science.current_tech.name) then
            iscience.update_tech_list(world)
            iui.update("construct.rml", "update_tech")
            w:pub {"research_finished", science.current_tech.name}
            science.current_tech = nil
            iui.open("message_pop.rml", {id = 2, items = {}, left = 170, top = 5})
        end
    end
    local queue = world:research_queue()
    if #queue > 0 then
        if not science.current_tech then
            science.current_tech = science.tech_tree[queue[1]]
        end
        science.current_tech.progress = world:research_progress(queue[1]) or 0
        iui.update("construct.rml", "update_tech", science.current_tech)
    elseif science.current_tech then
        science.current_tech = nil
    end
end
return update_world