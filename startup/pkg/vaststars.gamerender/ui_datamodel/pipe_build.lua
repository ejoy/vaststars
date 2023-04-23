local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local create_builder = ecs.require "editor.pipebuilder"
local iprototype = require "gameplay.interface.prototype"
local gesture_pan_mb = world:sub {"gesture", "pan"}
local dragdrop_camera_mb = world:sub {"dragdrop_camera"}

---------------
local M = {}
local builder

local function __get_event_handler()
    local events = {
        "start_laying",
        "finish_laying",
        "start_teardown",
        "finish_teardown",
        "confirm",
        "cancel",
        "place_one",
        "remove_one",
        "back",
    }

    local mbs = {}
    for _, event in ipairs(events) do
        local t = {}
        t.mb = mailbox:sub({event})
        t.func = function(...)
            if builder then
                builder[event](builder, ...)
            end
        end
        mbs[event] = t
    end
    return function(...)
        for _, t in pairs(mbs) do
            for _ in t.mb:unpack() do
                t.func(...)
            end
        end
    end
end
local event_handler = __get_event_handler()

function M:create()
    local datamodel = {
        show_start_laying = false,
        show_finish_laying = false,
        show_start_teardown = false,
        show_finish_teardown = false,
        show_confirm = false,
        show_cancel = false,
        show_place_one = false,
        show_remove_one = false,
    }

    builder = create_builder()
    local typeobject = iprototype.queryByName("管道1-X型")
    builder:new_entity(datamodel, typeobject)
    return datamodel
end

function M:stage_ui_update(datamodel)
    for _, _, e in gesture_pan_mb:unpack() do
        if e.state == "ended" then
            if builder then
                builder:touch_end(datamodel)
            end
        end
    end

    for _, delta in dragdrop_camera_mb:unpack() do
        if builder then
            builder:touch_move(datamodel, delta)
        end
    end

    event_handler(datamodel)
end

function M:stage_camera_usage(datamodel)
end

return M