local system = require "register.system"

local m = system "road"

local DIRTY_ROADNET <const> = 1 << 4

function m.build(world)
    if world._dirty & DIRTY_ROADNET == 0 then
        return
    end
    world:roadnet_reset()
end
