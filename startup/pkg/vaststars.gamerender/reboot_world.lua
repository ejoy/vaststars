local ecs = ...
local world = ecs.world
local w = world.w

local window = import_package "ant.window"
local global = require "global"

return function(feature, ...)
    global.startup_args = {...}

    window.reboot {
        feature = feature,
    }
end