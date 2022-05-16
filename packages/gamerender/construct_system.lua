local ecs = ...
local world = ecs.world

local construct_editor = ecs.require "construct_editor"
local construct_sys = ecs.system "construct_system"
local idetail = ecs.import.interface "vaststars.gamerender|idetail"

local single_touch_mb = world:sub {"single_touch"}
local pickup_mapping_mb = world:sub {"pickup_mapping"}
local dragdrop_camera_mb = world:sub {"dragdrop_camera"}
local pickup_mb = world:sub {"pickup"}
local single_touch_move_mb = world:sub {"single_touch", "MOVE"}


function construct_sys:camera_usage()
    for _, state in single_touch_mb:unpack() do
        if state == "END" or state == "CANCEL" then
            construct_editor:adjust_pickup_object()
        end
    end

    local leave = true
    for _, vsobject_id in pickup_mapping_mb:unpack() do
        if construct_editor.mode == "teardown" then
            construct_editor:teardown(vsobject_id)
        elseif construct_editor.mode == "normal" then
            if idetail.show(vsobject_id) then
                leave = false
            end
        end
    end

    -- 点击其它建筑 或 拖动时, 将弹出窗口隐藏
    for _ in pickup_mb:unpack() do
        if leave then
            world:pub {"ui_message", "leave"}
            leave = false
            break
        end
    end

    for _ in single_touch_move_mb:unpack() do
        if leave then
            world:pub {"ui_message", "leave"}
            leave = false
            break
        end
    end
end

function construct_sys:data_changed()
    for _, delta in dragdrop_camera_mb:unpack() do
        construct_editor:move_pickup_object(delta)
    end
end
