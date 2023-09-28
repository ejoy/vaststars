local ecs = ...
local world = ecs.world
local w = world.w

local debug_sys = ecs.system "debug_system"
local kb_mb = world:sub{"keyboard"}
local gameplay_core = require "gameplay.core"
local export_startup = ecs.require "export_startup"
local gesture_tap_mb = world:sub{"gesture", "tap"}
local math3d = require "math3d"
local YAXIS_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})
local PLANES <const> = {YAXIS_PLANE}
local terrain = ecs.require "terrain"
local icamera_controller = ecs.require "engine.system.camera_controller"

function debug_sys:init_world()
end

function debug_sys:ui_update()
    local w = world.w

    for _, key, press, state in kb_mb:unpack() do
        if key == "T" and press == 0 then
            local gameplay_world = gameplay_core.get_world()
            print(("current tick value of the gameplay world is: %d"):format(gameplay_world:now()))

            for e in gameplay_world.ecs:select "building:in road:absent eid:in solar_panel:in" do
                print(("solar panel %d efficiency: %f"):format(e.eid, e.solar_panel.efficiency))
                break
            end
        end

        if state.CTRL and key == "S" and press == 0 then
            export_startup()
        end
    end

    for _, _, v in gesture_tap_mb:unpack() do
        local x, y = v.x, v.y
        local pos = icamera_controller.screen_to_world(x, y, {PLANES[1]})
        local coord = terrain:get_coord_by_position(pos[1])
        if coord then
            log.info(("gesture tap coord: (%s, %s)"):format(coord[1], coord[2]))
            log.info(("group(%s)"):format(terrain:get_group_id(coord[1], coord[2])))

            local objects = require "objects"
            local vsobject_manager = ecs.require "vsobject_manager"
            local object = objects:coord(coord[1], coord[2])
            if object then
                local vsobject = assert(vsobject_manager:get(object.id), ("(%s) vsobject not found"):format(object.prototype_name))
                local game_object = vsobject.game_object
                log.info(("hitch id: %s"):format(game_object.hitchObject.tag.hitch[1]))
            end
        end
    end
end

