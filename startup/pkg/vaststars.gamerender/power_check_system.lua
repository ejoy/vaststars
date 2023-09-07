local ecs = ...
local world = ecs.world
local w = world.w

local ipower_check = {}
local power_check_sys = ecs.system "power_check_system"
local gameplay_core = require "gameplay.core"
local iprototype = import_package "vaststars.gamerender"("gameplay.interface.prototype")

local powerStatus = {}

local function updateStatus(ecs)
    local powergrids = {}
    for i = 1, 255 do
        local pg = ecs:object("powergrid", i+1)
        if pg.active == 0 then
            break
        end
        powergrids[i] = {
            pg.consumer_efficiency1,
            pg.consumer_efficiency2,
        }
    end
    for e in ecs:select "capacitance:in building:in eid:in" do
        local pg = powergrids[e.capacitance.network]
        if pg then
            local pt = iprototype.queryById(e.building.prototype)
            powerStatus[e.eid] = pg[pt.priority+1] > 0
        else
            powerStatus[e.eid] = false
        end
    end
end

function power_check_sys:gameworld_build()
    local gameplay_world = gameplay_core.get_world()
    local ecs = gameplay_world.ecs
    updateStatus(ecs)
end

function power_check_sys:gameworld_update()
    local gameplay_world = gameplay_core.get_world()
    local ecs = gameplay_world.ecs

    if gameplay_world:now() % 30 == 0 then
        updateStatus(ecs)
    end
end

function power_check_sys:gameworld_clean()
    powerStatus = {}
end

function ipower_check.is_powered_on(eid)
    return powerStatus[eid]
end

return ipower_check
