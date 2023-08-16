local system = require "register.system"

local m = system "luaecs"

function m.ecs_update(world)
    local ecs = world.ecs
    world:visitor_update()
    ecs:update()
end
