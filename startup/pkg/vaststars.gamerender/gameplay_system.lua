local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local igameplay = {}
local iprototype = require "gameplay.interface.prototype"
local gameplay = import_package "vaststars.gameplay"
local igameplay_building = gameplay.interface "building"

function igameplay.create_entity(init)
    local typeobject = assert(iprototype.queryByName(init.prototype_name), ("invalid prototype name: " .. init.prototype_name))
    local eid = gameplay_core.create_entity(init)
    world:pub {"gameplay", "create_entity", eid, typeobject}
    return eid
end

function igameplay.destroy_entity(eid)
    world:pub {"gameplay", "destroy_entity", eid}
    return igameplay_building.destroy(gameplay_core.get_world(), gameplay_core.get_entity(eid))
end

function igameplay.rotate(eid, dir)
    return igameplay_building.rotate(gameplay_core.get_world(), gameplay_core.get_entity(eid), dir)
end

function igameplay.move(eid, x, y)
    igameplay_building.move(gameplay_core.get_world(), gameplay_core.get_entity(eid), x, y)
end

return igameplay
