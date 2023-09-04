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
    for e in ecs:select "powergrid:in" do
        powergrids[#powergrids+1] = {e.powergrid.consumer_efficiency1, e.powergrid.consumer_efficiency2}
    end

    for e in ecs:select "capacitance:in building:in eid:in" do
        local typeobject = iprototype.queryById(e.building.prototype)
        local priority = typeobject.priority == "primary" and 1 or 2
        if e.capacitance.network == 0 then
            powerStatus[e.eid] = false
        else
            local powergrid = assert(powergrids[e.capacitance.network])
            powerStatus[e.eid] = assert(powergrid[priority]) > 0
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
