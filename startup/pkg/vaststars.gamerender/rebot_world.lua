local ecs = ...
local world = ecs.world
local w = world.w

local window = import_package "ant.window"
local global = require "global"

local function rebot(...)
    global.startup_args = {...}

    window.reboot {
        feature = {
            "vaststars.gamerender|gameplay",
        }
    }
end
return rebot