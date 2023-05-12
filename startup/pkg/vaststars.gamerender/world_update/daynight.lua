local ecs = ...
local world = ecs.world
local w = world.w

local DAYNIGHT_DEBUG <const> = require "debugger".daynight
local DuskTick <const> = require("gameplay.interface.constant").DuskTick
local NightTick <const> = require("gameplay.interface.constant").NightTick
local DayTick <const> = require("gameplay.interface.constant").DayTick
local idn = ecs.import.interface "ant.daynight|idaynight"

local daynight_update; do
    if DAYNIGHT_DEBUG then
        local function parse(s)
            if type(s) ~= "string" or s == "" then
                return s
            end
            local total_sec, day_ratio, night_ratio = s:match("(%d+):?(%d*):?(%d*)")
            return tonumber(total_sec), tonumber(day_ratio), tonumber(night_ratio)
        end

        local total_sec, day_ratio, night_ratio = parse(DAYNIGHT_DEBUG)
        day_ratio, night_ratio = day_ratio or 50, night_ratio or 50
        local total_ms = total_sec * 1000
        local day_ms = total_ms * (day_ratio / (day_ratio + night_ratio))

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

            local cycle = gettime() % total_ms
            if cycle >= 0 and cycle < day_ms then
                idn.update_day_cycle(dne, (cycle % day_ms)/day_ms)
            else
                idn.update_night_cycle(dne, (cycle - day_ms)/(total_ms - day_ms))
            end

            return false
        end
    else
        function daynight_update(gameplayWorld)
            local dne = w:first "daynight:in"
            if not dne then
                return false
            end

            local cycle = gameplayWorld:now() % DayTick
            if cycle >= 0 and cycle < DuskTick then
                idn.update_day_cycle(dne, (cycle % DuskTick)/DuskTick)
            elseif cycle < NightTick then
                idn.update_night_cycle(dne, (cycle - DuskTick)/(NightTick - DuskTick))
            else
                idn.update_day_cycle(dne, (cycle - NightTick)/(DayTick - NightTick))
            end

            return false
        end
    end
end
return daynight_update