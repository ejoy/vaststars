local ecs = ...
local world = ecs.world
local w = world.w

local global = require "global"
local math3d = require "math3d"
local objects = require "objects"
local vsobject_manager = ecs.require "vsobject_manager"
local interval_call = ecs.require "engine.interval_call"
local gameplay_core = require "gameplay.core"
local work_state_sys = ecs.system "work_state_system"

local EMISSIVE_COLOR_WORKING  = math3d.constant("v4", {0.0, 1.0, 0.0, 1})
local EMISSIVE_COLOR_LOWPOWER = math3d.constant("v4", {1.0, 0.9, 0.0, 1})
local EMISSIVE_COLOR_IDLE = math3d.constant("v4", {1.0, 0.0, 0.0, 1})

local STATUS_NONE <const> = 0
local STATUS_WORKING <const> = 1
local STATUS_IDLE <const> = 2

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
    for e in world.ecs:select "building:in road:absent eid:in chimney?in assembling?in wind_turbine?in solar_panel?in base?in" do
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
        local game_object = vsobject.game_object
        buildings[object.id].workstatus = buildings[object.id].workstatus or create_workstatus()
        local workstatus = buildings[object.id].workstatus
        if current == workstatus:get() then
            goto continue
        end
        workstatus:set(current)

        if current == STATUS_IDLE then
            game_object.on_idle()
            vsobject:update({emissive_color = EMISSIVE_COLOR_IDLE})
            vsobject:update({workstatus = "idle"})
        else
            game_object.on_work()
            vsobject:update({emissive_color = EMISSIVE_COLOR_WORKING})
            vsobject:update({workstatus = "work"})
        end
        -- TODO: low_power
        ::continue::
    end
end)

function work_state_sys:gameworld_update()
    update()
end