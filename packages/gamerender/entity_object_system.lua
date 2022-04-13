local ecs = ...
local world = ecs.world
local w = world.w

local entity_object_message_mb = world:sub {"entity_object_message"}
local entity_object_remove_mb = world:sub {"entity_object_remove"}

local entity_object_sys = ecs.system "entity_object_system"
local ientity_object = ecs.interface "ientity_object"

function entity_object_sys:entity_ready()
    for msg in entity_object_message_mb:each() do
        local events = msg[2]
        local event_type = msg[3]
        local e = world:entity(msg[4])
        local f = assert(events[event_type])
        f(e, table.unpack(msg, 5))
    end

    for _, eid in entity_object_remove_mb:unpack() do
        world:remove_entity(eid)
    end
end

function ientity_object.create(eid, events)
    local outer = {id = eid}
    function outer:send(msg, ...)
        world:pub {"entity_object_message", events, msg, eid, ...}
    end

    function outer:remove()
        world:pub {"entity_object_remove", eid}
    end
    return outer
end
