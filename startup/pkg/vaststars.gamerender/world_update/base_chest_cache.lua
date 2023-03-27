local ecs = ...
local world = ecs.world
local w = world.w

local global = require "global"
local iprototype = require "gameplay.interface.prototype"
local iui = ecs.import.interface "vaststars.gamerender|iui"

local function update_world()
    if  global.construct_queue:changed() then
        local construct_queue = {}
        for prototype_name in global.construct_queue:for_each() do
            local typeobject = iprototype.queryByName(prototype_name)
            local total_count = global.construct_queue:size(prototype_name)
            table.insert(construct_queue, {icon = typeobject.icon, count = total_count, total_count = total_count})
        end
        iui.update("construct.rml", "construct_queue", construct_queue)

        global.construct_queue:commit()
    end
end
return update_world