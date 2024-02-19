local system = require "register.system"

local m = system "luaecs"

function m.ecs_update(world)
    local ecs = world.ecs
    ecs:update()
end
