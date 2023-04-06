local ecs = ...
local world = ecs.world
local w = world.w

local global = require "global"
local update_interval = 25 --update per 25 frame
local counter = 1
local math3d = require "math3d"
local objects = require "objects"
local vsobject_manager = ecs.require "vsobject_manager"
local iprototype = import_package "vaststars.gamerender"("gameplay.interface.prototype")

local function get_object(x, y)
    local object = objects:coord(x, y)
    if object then
        return vsobject_manager:get(object.id)
    end
end

local EMISSIVE_COLOR_WORKING  = math3d.constant("v4", {0.0, 1.0, 0.0, 1})
local EMISSIVE_COLOR_IDLE = math3d.constant("v4", {1.0, 1.0, 0.0, 1})

local STATUS_NONE <const> = 0
local STATUS_WORKING <const> = 1
local STATUS_IDLE <const> = 2

local statuses = {} -- TODO: when an object is destroyed, clear it.
local last_frame_count = 0

return function(world)
    counter = counter + 1
    if counter < update_interval then
        return
    end
    counter = 1

    local statistic = global.statistic
    for e in world.ecs:select "building:in eid:in" do
        local vsobject = get_object(e.building.x, e.building.y)
        local typeobject = iprototype.queryById(e.building.prototype)
        local st = statistic.power[e.eid]
        if st then
            local game_object = vsobject.game_object
            statuses[e.eid] = statuses[e.eid] or {s = STATUS_NONE}
            local status = statuses[e.eid]

            -- is working ?
            if st.power < math.floor((world:now() - last_frame_count) * 0.5) * st.cfg.power and
                not iprototype.has_type(typeobject.type, "generator") then
                game_object.on_idle()
                vsobject:emissive_color_update(EMISSIVE_COLOR_IDLE)
                if vsobject:has_animation("idle_start") then
                    if status.s ~= STATUS_IDLE then
                        status.s = STATUS_IDLE
                        vsobject:animation_name_update("idle_start", false)
                    end
                else
                    vsobject:animation_name_update("idle", true)
                end
            else
                game_object.on_work()
                vsobject:emissive_color_update(EMISSIVE_COLOR_WORKING)
                if vsobject:has_animation("work_start") then
                    if status.s ~= STATUS_WORKING then
                        status.s = STATUS_WORKING
                        vsobject:animation_name_update("work_start", false)
                    end
                else
                    vsobject:animation_name_update("work", true)
                end
            end
            -- TODO: low_power
        end
    end

    for e in world.ecs:select "REMOVED building:in" do
        print("REMOVED building:in", e.eid)
    end

    last_frame_count = world:now()
end