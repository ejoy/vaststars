local ecs = ...
local world = ecs.world
local w = world.w

local global = require "global"
local update_interval = 25 --update per 25 frame
local counter = 1
local math3d = require "math3d"
local objects = require "objects"
local vsobject_manager = ecs.require "vsobject_manager"

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
    local function set(self, s)
        status = s
    end
    local function get(self, s)
        return status
    end
    return {
        on_position_change = on_position_change,
        remove = remove,
        set = set,
        get = get,
    }
end

local function get_workstatus(world, e)
    if e.assembling then
        return e.assembling.progress > 0 and STATUS_WORKING or STATUS_IDLE
    end
    if e.wind_turbine or e.solar_panel or e.base then
        return STATUS_WORKING
    end
end

return function(world)
    counter = counter + 1
    if counter < update_interval then
        return
    end
    counter = 1

    local buildings = global.buildings
    for e in world.ecs:select "building:in eid:in assembling?in wind_turbine?in solar_panel?in base?in" do
        local object = assert(objects:coord(e.building.x, e.building.y))
        local vsobject = vsobject_manager:get(object.id)
        local game_object = vsobject.game_object
        buildings[object.id].workstatus = buildings[object.id].workstatus or create_workstatus()
        local workstatus = buildings[object.id].workstatus
        local current = get_workstatus(world, e)
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

    for e in world.ecs:select "REMOVED building:in" do
        print("REMOVED building:in", e.eid)
    end
end