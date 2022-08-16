local ecs = ...
local world = ecs.world
local w = world.w

local entity_object_message_mb = world:sub {"entity_object_message"}
local entity_object_remove_mb = world:sub {"entity_object_remove"}

local entity_object_sys = ecs.system "entity_object_system"
local ientity_object = ecs.interface "ientity_object"

function entity_object_sys:entity_ready()
    for msg in entity_object_message_mb:each() do
        local object = msg[2]
        local events = msg[3]
        local event_type = msg[4]
        local e <close> = w:entity(msg[5])
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
        world:pub {"entity_object_remove", eid}
    end
    return outer
end
