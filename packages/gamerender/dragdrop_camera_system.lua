local ecs = ...
local world = ecs.world
local w = world.w

local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local math3d = require "math3d"
local camera = ecs.require "camera"

local dragdrop_camera_sys = ecs.system "dragdrop_camera_system"
local touch_mb = world:sub {"touch"}
local begin_pos
local touch_id

function dragdrop_camera_sys:camera_usage()
    local last_move_x, last_move_y
    for _, state, datas in touch_mb:unpack() do
        for _, data in pairs(datas) do
            if state == "START" then
                if not touch_id then
                    begin_pos = math3d.ref(camera.screen_to_world(data.x, data.y))
                    touch_id = data.id
                end

            elseif state == "MOVE" then
                if touch_id == data.id then
                    last_move_x, last_move_y = data.x, data.y
                end

            elseif state == "CANCEL" or state == "END" then
                if touch_id == data.id then
                    begin_pos = nil
                    touch_id = nil
                end
            end
        end
    end

    if begin_pos and last_move_x and last_move_y then
        local pos = camera.screen_to_world(last_move_x, last_move_y)
        local mq = w:singleton("main_queue", "camera_ref:in render_target:in")
        local ce = world:entity(mq.camera_ref)
        local delta = math3d.inverse(math3d.sub(pos, begin_pos))
        iom.move_delta(ce, delta)

        world:pub {"dragdrop_camera", math3d.ref(delta)}
    end
end