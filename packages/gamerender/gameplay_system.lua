local ecs = ...
local world = ecs.world
local w = world.w
local gameplay_core = require "gameplay.core"

local igameplay = ecs.interface "igameplay"

function igameplay.create_entity(init)
    local eid = gameplay_core.create_entity(init)
    world:pub {"gameplay", "create_entity", eid, init.prototype_name}
    return eid
end

function igameplay.remove_entity(eid)
    world:pub {"gameplay", "remove_entity", eid}
    return gameplay_core.remove_entity(eid)
end