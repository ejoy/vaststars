local ecs = ...
local world = ecs.world
local w = world.w

local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local math3d = require "math3d"
local camera = ecs.require "engine.camera"

local YAXIS_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})
local PLANES <const> = {YAXIS_PLANE}
local dragdrop_camera_sys = ecs.system "dragdrop_camera_system"
local single_touch_mb = world:sub {"single_touch"}
local begin_pos

function dragdrop_camera_sys:camera_usage()
    local last_move_x, last_move_y
    for _, state, data in single_touch_mb:unpack() do
        if state == "START" then
            begin_pos = math3d.ref(camera.screen_to_world(data.x, data.y, PLANES)[1])

        elseif state == "MOVE" then
            last_move_x, last_move_y = data.x, data.y

        elseif state == "CANCEL" or state == "END" then
            begin_pos = nil
        end
    end

    if begin_pos and last_move_x and last_move_y then
        local pos = camera.screen_to_world(last_move_x, last_move_y, PLANES)[1]
        local mq = w:first("main_queue camera_ref:in")
        local ce <close> = w:entity(mq.camera_ref)
        local delta = math3d.sub(begin_pos, pos)
        iom.move_delta(ce, delta)

        world:pub {"dragdrop_camera", math3d.ref(delta)}
    end
end