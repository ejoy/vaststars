local ecs = ...
local world = ecs.world
local w = world.w

local function send(self, ...)
    world:instance_message(self.instance, ...)
end

local function remove(self)
    world:remove_instance(self.instance)
end

local m = {}
function m.create(instance, events)
    local outer = {instance = instance}
    outer.send = send
    outer.remove = remove
    for _, v in ipairs(events) do
        outer[v] = function (self, ...)
            send(self, v, ...)
        end
    end
    return outer
end

return m