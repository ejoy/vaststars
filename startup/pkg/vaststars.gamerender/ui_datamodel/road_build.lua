local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local create_builder = ecs.require "editor.roadbuilder"
local iprototype = require "gameplay.interface.prototype"
local single_touch_mb = world:sub {"single_touch"}
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
    local typeobject = iprototype.queryByName("砖石公路-X型")
    builder:new_entity(datamodel, typeobject)
    return datamodel
end

function M:stage_ui_update(datamodel)
    for _, state in single_touch_mb:unpack() do
        if state == "END" or state == "CANCEL" then
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