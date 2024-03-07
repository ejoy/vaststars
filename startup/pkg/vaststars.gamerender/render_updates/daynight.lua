local ecs = ...
local world = ecs.world
local w = world.w

local DAYNIGHT_DEBUG <const> = ecs.require "game_settings".daynight
local DayTick <const> = require("gameplay.interface.constant").DayTick
local idn = ecs.require "ant.daynight|daynight"
local gameplay_core = require "gameplay.core"
local itimer = ecs.require "ant.timer|timer_system"

local daynight_sys = ecs.system "daynight_system"

local daynight_update; do
    if not DAYNIGHT_DEBUG then
        function daynight_update()
        end
    elseif DAYNIGHT_DEBUG then
        assert(tonumber(DAYNIGHT_DEBUG), "daynight must be a number")

        local total_sec = DAYNIGHT_DEBUG
        local total_ms = total_sec * 1000

        local ltask = require "ltask"
        local function gettime()
            local _, now = itimer.now()
            return now * 10
        end

        function daynight_update()
            local dne = assert(w:first "daynight:in")
            idn.update_cycle(dne, (gettime() % total_ms)/total_ms)
        end
    else
        function daynight_update(gameplayWorld)
            -- 0, 0.15 dawn
            -- 0.15, 0.55 day
            -- 0.55, 0.7 dusk
            -- 0.7, 0.85 night
            -- 0.85, 1 dawn
            local dne = assert(w:first "daynight:in")
            local t = (gameplayWorld:now() % DayTick)/DayTick
            idn.update_cycle(dne, (t + 0.55) % 1) -- begin from dusk
        end
    end
end

function daynight_sys:gameworld_update()
    daynight_update(gameplay_core.get_world())
end