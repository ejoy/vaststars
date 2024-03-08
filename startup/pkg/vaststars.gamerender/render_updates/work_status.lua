local ecs = ...
local world = ecs.world
local w = world.w

local STATUS_NONE <const> = 0
local STATUS_WORKING <const> = 1
local STATUS_IDLE <const> = 2
local STATUS_NO_POWER <const> = 3
local STATUS_WORK_START <const> = 4
local STATUS_IDLE_START <const> = 5

local STATUS = {
    [STATUS_WORKING] = "work",
    [STATUS_IDLE] = "idle",
    [STATUS_NO_POWER] = "idle",
    [STATUS_WORK_START] = "work_start",
    [STATUS_IDLE_START] = "idle_start",
}

local COLOR <const> = ecs.require "vaststars.prototype|color"
local COLOR = {
    [STATUS_WORKING] = COLOR.WORK_STATE_WORKING,
    [STATUS_IDLE] = COLOR.WORK_STATE_IDLE,
    [STATUS_NO_POWER] = COLOR.WORK_STATE_NO_POWER,
    [STATUS_WORK_START] = COLOR.WORK_STATE_WORKING,
    [STATUS_IDLE_START] = COLOR.WORK_STATE_IDLE,
}

local objects = require "objects"
local vsobject_manager = ecs.require "vsobject_manager"
local gameplay_core = require "gameplay.core"
local work_status_sys = ecs.system "work_status_system"
local ipower_check = ecs.require "power_check_system"
local iprototype = require "gameplay.interface.prototype"
local itl = ecs.require "ant.timeline|timeline"
local itimer = ecs.require "utility.timer"

local work_statuses = {} -- gameplay_eid -> work_status
local timer = itimer.new()

local function get_working_status(e)
    if e.capacitance and not ipower_check.is_powered_on(gameplay_core.get_world(), e) then
        return STATUS_NO_POWER
    end
    if e.accumulator and e.capacitance then
        return e.capacitance.delta ~= 0 and STATUS_WORKING or STATUS_IDLE
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
    if e.laboratory then
        return e.laboratory.progress > 0 and STATUS_WORKING or STATUS_IDLE
    end
end

local function _get_vsobject(x, y)
    local object = assert(objects:coord(x, y))
    return vsobject_manager:get(object.id) or error(("(%s,%s) (%s) vsobject not found"):format(x, y, object.prototype_name))
end

local check_start = {
    [STATUS_WORKING] = function(prototype, old)
        if old == STATUS_NONE or old == STATUS_WORK_START then
            return STATUS_WORKING
        end
        local typeobject = iprototype.queryById(prototype)
        if not typeobject.work_status then
            return STATUS_WORKING
        end
        return typeobject.work_status.work_start and STATUS_WORK_START or STATUS_WORKING
    end,
    [STATUS_IDLE] = function(prototype, old)
        if old == STATUS_NONE or old == STATUS_IDLE_START then
            return STATUS_IDLE
        end
        local typeobject = iprototype.queryById(prototype)
        if not typeobject.work_status then
            return STATUS_IDLE
        end
        return typeobject.work_status.idle_start and STATUS_IDLE_START or STATUS_IDLE
    end,
}

local function _update_work_status()
    local world = gameplay_core.get_world()
    for e in world.ecs:select "building:in road:absent eid:in capacitance?in chimney?in assembling?in wind_turbine?in solar_panel?in base?in laboratory?in" do
        -- only some buildings have a working status
        local current = get_working_status(e)
        if not current then
            goto continue
        end

        local work_status = work_statuses[e.eid] or STATUS_NONE
        if current == work_status then
            goto continue
        end

        local func = check_start[current]
        if func then
            current = func(e.building.prototype, work_status)
        end

        work_statuses[e.eid] = current

        local vsobject = _get_vsobject(e.building.x, e.building.y)
        vsobject:update {work_status = STATUS[current], emissive_color = COLOR[current]}
        ::continue::
    end

    for e in w:select "timeline:in loop_timeline:absent" do
        itl:start(e)
    end
end

function work_status_sys:gameworld_prebuild()
    local world = gameplay_core.get_world()
    for e in world.ecs:select "REMOVED eid:in" do
        work_statuses[e.eid] = nil
    end
end

function work_status_sys:gameworld_build()
    _update_work_status()
end

function work_status_sys:init_world()
    -- switch the working status of all machines every 3 seconds
    timer:interval(90, _update_work_status)
end

function work_status_sys:gameworld_update()
    timer:update()
end

function work_status_sys:exit()
    work_statuses = {}
end