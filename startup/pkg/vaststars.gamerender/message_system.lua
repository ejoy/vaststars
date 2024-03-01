local ecs = ...
local world = ecs.world
local w = world.w

local m = ecs.system "message_system"

local evEntityMessage = world:sub { "entity-message" }
local evInstanceMessage = world:sub { "instance-message" }

local EntityEvent = {}
local InstanceEvent = {}

function m:data_changed()
    for msg in evEntityMessage:each() do
        local name = msg[2]
        local eid = msg[3]
        local func = EntityEvent[name]
        if func then
            local v = w:fetch(eid)
            if v then
                func(v, table.unpack(msg, 4))
                w:submit(v)
            end
        end
    end
    for msg in evInstanceMessage:each() do
        local name = msg[2]
        local func = InstanceEvent[name]
        if func then
            func(table.unpack(msg, 3))
        end
    end
end


local api = {}

function api.entity_sub(name, func)
    assert(EntityEvent[name] == nil)
    EntityEvent[name] = func
end

function api.entity_pub(name, eid, ...)
    world:pub { "entity-message", name, eid, ... }
end

function api.instance_sub(name, func)
    assert(InstanceEvent[name] == nil)
    InstanceEvent[name] = func
end

function api.instance_pub(name, instance, ...)
    world:pub { "instance-message", name, instance, ... }
end

return api
