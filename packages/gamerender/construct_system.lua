local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = ecs.require "gameplay.core"
import_package "vaststars.prototype"
local camera = ecs.require "engine.camera"
local construct_editor = ecs.require "construct_editor"

local construct_sys = ecs.system "construct_system"
local iconstruct = ecs.interface "iconstruct"
local ui_construct_entity_mb = world:sub {"ui", "construct", "construct_entity"}
local ui_construct_begin_mb = world:sub {"ui", "construct", "construct_begin"} -- 建造模式
local ui_construct_confirm_mb = world:sub {"ui", "construct", "construct_confirm"} -- 确认建造
local ui_construct_complete_mb = world:sub {"ui", "construct", "construct_complete"} -- 开始施工
local ui_construct_rotate_mb = world:sub {"ui", "construct", "rotate"}
local ui_construct_cancel_mb = world:sub {"ui", "construct", "cancel"}
local ui_construct_dismantle_begin_mb = world:sub {"ui", "construct", "dismantle_begin"}
local ui_construct_dismantle_complete_mb = world:sub {"ui", "construct", "dismantle_complete"}
local ui_construct_fluidbox_update_mb = world:sub {"ui", "construct", "fluidbox_update"}

local single_touch_mb = world:sub {"single_touch"}
local pickup_mapping_mb = world:sub {"pickup_mapping"}
local dragdrop_camera_mb = world:sub {"dragdrop_camera"}

local teardown = false

function construct_sys:camera_usage()
    for _, _, _, prototype_name in ui_construct_entity_mb:unpack() do
        construct_editor:new_pickup_object(prototype_name)
    end

    for _, state in single_touch_mb:unpack() do
        if state == "END" or state == "CANCEL" then
            construct_editor:adjust_pickup_object()
        end
    end
end

function construct_sys:data_changed()
    for _, delta in dragdrop_camera_mb:unpack() do
        construct_editor:move_pickup_object(delta)
    end

    for _, _, _, double_confirm in ui_construct_begin_mb:unpack() do
        if construct_editor:check_unconfirmed(double_confirm) then
            world:pub {"ui_message", "show_unconfirmed_double_confirm"}
            goto continue
        end
        if not double_confirm then
            world:pub {"ui_message", "unconfirmed_double_confirm_continuation"}
            goto continue
        end

        teardown = false
        construct_editor:construct_begin()
        gameplay_core.world_update = false
        camera.set("camera_construct.prefab")
        ::continue::
    end

    for _ in ui_construct_rotate_mb:unpack() do
        assert(gameplay_core.world_update == false)
        construct_editor:rotate_pickup_object()
    end

    for _ in ui_construct_confirm_mb:unpack() do
        assert(gameplay_core.world_update == false)
        if construct_editor:confirm() then
            world:pub {"ui_message", "show_construct_complete", true}
        end
    end

    for _ in ui_construct_complete_mb:unpack() do
        construct_editor:complete()
        gameplay_core.world_update = true
        camera.set("camera_default.prefab")
    end

    for _, _, _, double_confirm in ui_construct_cancel_mb:unpack() do
        if construct_editor:check_unconfirmed(double_confirm) then
            world:pub {"ui_message", "show_unconfirmed_double_confirm"}
            goto continue
        end
        if not double_confirm then
            world:pub {"ui_message", "unconfirmed_double_confirm_continuation"}
            goto continue
        end

        construct_editor:cancel()
        teardown = false
        gameplay_core.world_update = true
        camera.set("camera_default.prefab")
        ::continue::
    end

    for _, _, _, double_confirm in ui_construct_dismantle_begin_mb:unpack() do
        if construct_editor:check_unconfirmed(double_confirm) then
            world:pub {"ui_message", "show_unconfirmed_double_confirm"}
            goto continue
        end
        if not double_confirm then
            world:pub {"ui_message", "unconfirmed_double_confirm_continuation"}
            goto continue
        end

        construct_editor:teardown_begin()
        teardown = true
        gameplay_core.world_update = false
        camera.set("camera_construct.prefab")
        ::continue::
    end

    for _ in ui_construct_dismantle_complete_mb:unpack() do
        construct_editor:teardown_complete()
        teardown = false
        gameplay_core.world_update = true
        camera.set("camera_default.prefab")
    end

    for _, _, _, fluid_name in ui_construct_fluidbox_update_mb:unpack() do
        construct_editor:set_pickup_object_fluid(fluid_name)
    end
end

function construct_sys:pickup_mapping()
    for _, vsobject_id in pickup_mapping_mb:unpack() do
        if teardown then
            construct_editor:teardown(vsobject_id)
        end
    end
end

function iconstruct.reset()
    teardown = false
end
