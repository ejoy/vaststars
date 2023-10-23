local ecs = ...
local world = ecs.world
local w = world.w

local ipower_check = {}
local power_check_sys = ecs.system "power_check_system"
local gameplay_core = require "gameplay.core"
local iprototype = import_package "vaststars.gamerender"("gameplay.interface.prototype")

local PowerGrids = {}

local function updateStatus(ecs)
    for i = 1, 255 do
        local pg = ecs:object("powergrid", i+1)
        if pg.active == 0 then
            break
        end
        PowerGrids[i] = {
            consumer = {
                pg.consumer_efficiency1,
                pg.consumer_efficiency2,
            },
            generator = {
                pg.generator_efficiency1,
                pg.generator_efficiency2,
            },
            accumulator = pg.accumulator_efficiency,
        }
    end
end

function power_check_sys:gameworld_beforebuild()
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
    PowerGrids = {}
end

function ipower_check.is_powered_on(world, e)
    world.ecs:extend(e, "consumer?in generator?in accumulator?in capacitance?in")
    if not e.capacitance and not e.generator and not e.accumulator then
        return true
    end

    world.ecs:extend(e, "capacitance:in building:in")
    local pg = PowerGrids[e.capacitance.network]
    if pg then
        local pt = iprototype.queryById(e.building.prototype)
        if e.consumer then
            return pg.consumer[pt.priority+1] > 0
        elseif e.generator then
            return pg.generator[pt.priority+1] > 0
        elseif e.accumulator then
            return pg.accumulator > 0
        end
    else
        return false
    end
end

return ipower_check
