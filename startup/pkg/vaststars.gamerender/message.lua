local ecs = ...
local world = ecs.world
local w = world.w

local m = ecs.system "message_system"
local evInstanceMessage = world:sub { "instance-message" }

local InstanceEvent = {}

function m:data_changed()
    for msg in evInstanceMessage:each() do
        local name = msg[2]
        local func = InstanceEvent[name]
        func(table.unpack(msg, 3))
    end
end

local api = {}

function api:sub(name, func)
    assert(InstanceEvent[name] == nil)
    InstanceEvent[name] = func
end

function api:pub(name, instance, ...)
    assert(InstanceEvent[name])
    world:pub { "instance-message", name, instance, ... }
end

return api
