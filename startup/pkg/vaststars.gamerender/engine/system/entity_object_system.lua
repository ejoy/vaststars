local ecs = ...
local world = ecs.world
local w = world.w

local entity_object_message_mb = world:sub {"entity_object_message"}
local entity_object_remove_mb = world:sub {"entity_object_remove"}

local entity_object_sys = ecs.system "entity_object_system"
local ientity_object = {}

-- it must be after the scene_update stage, otherwise you cannot obtain the entity's correct world matrix
function entity_object_sys:ui_update()
    for msg in entity_object_message_mb:each() do
        local object = msg[2]
        local events = msg[3]
        local event_type = msg[4]
        local e <close> = assert(world:entity(msg[5]), "entity has been removed")
        local f = assert(events[event_type])
        f(object, e, table.unpack(msg, 6))
    end

    for _, eid in entity_object_remove_mb:unpack() do
        w:remove(eid)
    end
end

function ientity_object.create(eid, events)
    local outer = {id = eid}
    function outer:send(msg, ...)
        world:pub {"entity_object_message", self, events, msg, eid, ...}
    end

    function outer:remove()
        assert(self.id ~= 0, "entity_object already removed")
        world:pub {"entity_object_remove", self.id}
        self.id = 0
    end
    return outer
end

return ientity_object
