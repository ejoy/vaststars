local ecs = ...
local world = ecs.world
local w = world.w

local construct_sys = ecs.system "construct_system"

local ui_construct_begin_mb = world:sub {"ui", "construct", "construct_begin"}       -- 建造模式
local ui_construct_entity_mb = world:sub {"ui", "construct", "construct_entity"}
local ui_construct_complete_mb = world:sub {"ui", "construct", "construct_complete"} -- 开始施工

function construct_sys:data_changed()
    for _ in ui_construct_begin_mb:unpack() do
        print("construct")
    end

    for _ in ui_construct_complete_mb:unpack() do
        print("construct complete")
    end
end

function construct_sys:camera_usage()
    for _, _, _, prototype in ui_construct_entity_mb:unpack() do
        print(prototype)
    end
end
