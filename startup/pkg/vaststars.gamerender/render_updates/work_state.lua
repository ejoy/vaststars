local ecs = ...
local world = ecs.world
local w = world.w

local global = require "global"
local objects = require "objects"
local vsobject_manager = ecs.require "vsobject_manager"
local interval_call = ecs.require "engine.interval_call"
local gameplay_core = require "gameplay.core"
local work_state_sys = ecs.system "work_state_system"
local ipower_check = ecs.require "power_check_system"
local SPRITE_COLOR <const> = import_package "vaststars.prototype"("sprite_color")

local STATUS_NONE <const> = 0
local STATUS_WORKING <const> = 1
local STATUS_IDLE <const> = 2
local STATUS_NO_POWER <const> = 3

local COLOR = {
    [STATUS_WORKING] = SPRITE_COLOR.WORK_STATE_WORKING,
    [STATUS_IDLE] = SPRITE_COLOR.WORK_STATE_IDLE,
    [STATUS_NO_POWER] = SPRITE_COLOR.WORK_STATE_NO_POWER,
}

local STATUS = {
    [STATUS_WORKING] = "work",
    [STATUS_IDLE] = "idle",
    [STATUS_NO_POWER] = "idle",
}

local function create_workstatus()
    local status = STATUS_NONE
    local function on_position_change()
    end
    local function remove()
    end
    local function set(_, s)
        status = s
    end
    local function get()
        return status
    end
    return {
        on_position_change = on_position_change,
        remove = remove,
        set = set,
        get = get,
    }
end

local function get_working_state(e)
    if e.capacitance and not ipower_check.is_powered_on(gameplay_core.get_world(), e) then
        return STATUS_NO_POWER
    end
    if e.assembling then
        return e.assembling.progress > 0 and STATUS_WORKING or STATUS_IDLE
    end
    if e.chimney then
        return e.chimney.progress > 0 and STATUS_WORKING or STATUS_IDLE
    end
    if e.wind_turbine or e.base then
        return STATUS_WORKING
    end
    if e.solar_panel then
        return e.solar_panel.efficiency > 0 and STATUS_WORKING or STATUS_IDLE
    end
end

-- switch the working status of all machines every 3 seconds
local update = interval_call(3000, function()
    local world = gameplay_core.get_world()
    local buildings = global.buildings
    for e in world.ecs:select "building:in road:absent eid:in capacitance?in chimney?in assembling?in wind_turbine?in solar_panel?in base?in" do
        -- only some buildings have a working state
        local current = get_working_state(e)
        if not current then
            goto continue
        end

        -- object may not have been fully created yet
        local object = objects:coord(e.building.x, e.building.y)
        if not object then
            goto continue
        end

        local vsobject = assert(vsobject_manager:get(object.id), ("(%s) vsobject not found"):format(object.prototype_name))
        buildings[object.id].workstatus = buildings[object.id].workstatus or create_workstatus()
        local workstatus = buildings[object.id].workstatus
        if current == workstatus:get() then
            goto continue
        end
        workstatus:set(current)
        vsobject:update({workstatus = STATUS[current], emissive_color = COLOR[current]})
        ::continue::
    end
end)

function work_state_sys:gameworld_update()
    local w = world.w
    update()
end