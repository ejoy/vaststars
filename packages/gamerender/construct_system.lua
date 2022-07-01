local ecs = ...
local world = ecs.world

local global = require "global"
local construct_sys = ecs.system "construct_system"
local idetail = ecs.import.interface "vaststars.gamerender|idetail"
local ieditor = ecs.require "editor.editor"

local pickup_mapping_mb = world:sub {"pickup_mapping"}
local pickup_mb = world:sub {"pickup"}
local single_touch_move_mb = world:sub {"single_touch", "MOVE"}
local objects = require "objects"
local icamera = ecs.require "engine.camera"
local math3d = require "math3d"
local terrain = ecs.require "terrain"

function construct_sys:camera_usage()
    local leave = true
    for _, _, x, y, object_id in pickup_mapping_mb:unpack() do
        local coord = terrain:align(icamera.screen_to_world(x, y), 1, 1)
        print(coord[1], coord[2])

        if global.mode == "teardown" then
            ieditor:teardown(object_id)
        elseif global.mode == "normal" then
            if objects:get(object_id) then -- TODO: object_id may be 0
                if idetail.show(object_id) then
                    leave = false
                end
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
