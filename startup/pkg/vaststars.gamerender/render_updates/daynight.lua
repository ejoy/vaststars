local ecs = ...
local world = ecs.world
local w = world.w

local DAYNIGHT_DEBUG <const> = ecs.require "game_settings".daynight
local DayTick <const> = require("gameplay.interface.constant").DayTick
local idn = ecs.require "ant.daynight|daynight"
local gameplay_core = require "gameplay.core"

local daynight_sys = ecs.system "daynight_system"
local last_cycle, cur_cycle = 0, 0
local type = 0

local daynight_update; do
    if DAYNIGHT_DEBUG == "" then
        function daynight_update()
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
            cur_cycle = (gettime() % total_ms)/total_ms
            if last_cycle > cur_cycle then
                type = type == 0 and 1 or 0
            end
            for e in w:select "daynight:in" do
                if e.daynight.type == type then
                    idn.update_cycle(e, cur_cycle)
                end
            end
            last_cycle = cur_cycle
        end
    else
        function daynight_update(gameplayWorld)
            cur_cycle = (gameplayWorld:now() % DayTick)/DayTick
            if last_cycle > cur_cycle then
                type = type == 0 and 1 or 0
            end
            for e in w:select "daynight:in" do
                if e.daynight.type == type then
                    idn.update_cycle(e, cur_cycle)
                end
            end
            last_cycle = cur_cycle
        end
    end
end

function daynight_sys:gameworld_update()
    daynight_update(gameplay_core.get_world())
end