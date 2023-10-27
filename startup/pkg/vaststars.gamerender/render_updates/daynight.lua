local ecs = ...
local world = ecs.world
local w = world.w

local DAYNIGHT_DEBUG <const> = ecs.require "debugger".daynight
local DayTick <const> = require("gameplay.interface.constant").DayTick
local idn = ecs.require "ant.daynight|daynight"
local gameplay_core = require "gameplay.core"

local daynight_sys = ecs.system "daynight_system"

local daynight_update; do
    if DAYNIGHT_DEBUG == "" then
        function daynight_update()
            return false
        end
    elseif DAYNIGHT_DEBUG then
        local total_sec = tostring(DAYNIGHT_DEBUG)
        local total_ms = total_sec * 1000

        local ltask = require "ltask"
        local function gettime()
            local _, now = ltask.now()
            return now * 10
        end

        function daynight_update()
            local dne = w:first "daynight:in"
            if not dne then
                return false
            end

            idn.update_cycle(dne, (gettime() % total_ms)/total_ms)
            return false
        end
    else
        function daynight_update(gameplayWorld)
            local dne = w:first "daynight:in"
            if not dne then
                return false
            end

            idn.update_cycle(dne, (gameplayWorld:now() % DayTick)/DayTick)
            return false
        end
    end
end

function daynight_sys:gameworld_update()
    daynight_update(gameplay_core.get_world())
end