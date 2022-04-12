local ecs = ...
local world = ecs.world
local w = world.w

local entity_object_message_mb = world:sub {"entity_object_message"}
local entity_object_remove_mb = world:sub {"entity_object_remove"}

local entity_object_sys = ecs.system "entity_object_system"
local ientity_object = ecs.interface "ientity_object"

function entity_object_sys:entity_ready()
    for msg in entity_object_message_mb:each() do
        local f = msg[2]
        local e = world:entity(msg[3])
        f(e, table.unpack(msg, 4))
    end

    for _, eid in entity_object_remove_mb:unpack() do
        world:remove_entity(eid)
    end
end

function ientity_object.create(eid, object)
    local on_message = object.on_message
    if not on_message then
        return
    end

    local outer = {id = eid}
    if on_message then
        function outer:send(...)
            world:pub {"entity_object_message", on_message, eid, ...}
        end
    end
    function outer:remove()
        world:pub {"entity_object_remove", eid}
    end
    return outer
end
