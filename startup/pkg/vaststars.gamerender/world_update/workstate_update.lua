local ecs = ...
local world = ecs.world
local w = world.w

local global = require "global"
local math3d = require "math3d"
local objects = require "objects"
local vsobject_manager = ecs.require "vsobject_manager"
local iprototype = require "gameplay.interface.prototype"

local EMISSIVE_COLOR_WORKING  = math3d.constant("v4", {0.0, 1.0, 0.0, 1})
local EMISSIVE_COLOR_IDLE = math3d.constant("v4", {1.0, 1.0, 0.0, 1})

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
    local function get(_, s)
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
    if e.wind_turbine or e.base then
        return STATUS_WORKING
    end
    if e.solar_panel then
        return e.solar_panel.efficiency > 0 and STATUS_WORKING or STATUS_IDLE
    end
end

return function(world)
    local buildings = global.buildings
    for e in world.ecs:select "building:in eid:in assembling?in wind_turbine?in solar_panel?in base?in" do
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
            vsobject:emissive_color_update(EMISSIVE_COLOR_IDLE)
            if vsobject:has_animation("idle_start") then
                vsobject:animation_name_update("idle_start", true)
            else
                vsobject:animation_name_update("idle", false)
            end
        else
            game_object.on_work()
            vsobject:emissive_color_update(EMISSIVE_COLOR_WORKING)
            if vsobject:has_animation("work_start") then
                vsobject:animation_name_update("work_start", true)
            else
                vsobject:animation_name_update("work", false)
            end
        end
        -- TODO: low_power
        ::continue::
    end
end