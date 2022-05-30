local ecs = ...
local world = ecs.world

local global = require "global"
local construct_sys = ecs.system "construct_system"
local idetail = ecs.import.interface "vaststars.gamerender|idetail"
local ieditor = ecs.require "editor.editor"

local pickup_mapping_mb = world:sub {"pickup_mapping"}
local pickup_mb = world:sub {"pickup"}
local single_touch_move_mb = world:sub {"single_touch", "MOVE"}

function construct_sys:camera_usage()
    local leave = true
    for _, vsobject_id in pickup_mapping_mb:unpack() do
        if global.mode == "teardown" then
            ieditor:teardown(vsobject_id)
        elseif global.mode == "normal" then
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

end
