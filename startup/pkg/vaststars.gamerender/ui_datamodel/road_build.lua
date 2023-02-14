local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local create_roadbuilder = ecs.require "editor.roadbuilder"
local iprototype = require "gameplay.interface.prototype"
local single_touch_mb = world:sub {"single_touch"}
local dragdrop_camera_mb = world:sub {"dragdrop_camera"}
local batch_construct_begin_mb = mailbox:sub {"batch_construct_begin"}
local batch_construct_end_mb = mailbox:sub {"batch_construct_end"}
local construct_mb = mailbox:sub {"construct"}
local cancel_mb = mailbox:sub {"cancel"}
local confirm_mb = mailbox:sub {"confirm"}
local teardown_mb = mailbox:sub {"teardown"}
local batch_teardown_begin_mb = mailbox:sub {"batch_teardown_begin"}

---------------
local M = {}
local builder

function M:create()
    local datamodel = {
        show_confirm = false,
        show_batch_teardown_begin = false,
        show_batch_construct_begin = false,
        show_construct = false,
        show_teardown = false,
        show_batch_teardown_end = false,
        show_batch_construct_end = false,
        show_cancel = false,
    }

    builder = create_roadbuilder()
    local typeobject = iprototype.queryByName("entity", "砖石公路-X型-01")
    builder:new_entity(datamodel, typeobject)

    return datamodel
end

function M:stage_ui_update(datamodel)
    for _, state in single_touch_mb:unpack() do
        if state == "END" or state == "CANCEL" then
            if builder then
                builder:touch_end(datamodel)
                self:flush()
            end
        end
    end

    for _, delta in dragdrop_camera_mb:unpack() do
        if builder then
            builder:touch_move(datamodel, delta)
            self:flush()
        end
    end

    for _ in batch_construct_begin_mb:unpack() do
        builder:laying_pipe_begin(datamodel)
        self:flush()
    end

    for _ in cancel_mb:unpack() do
        builder:laying_pipe_cancel(datamodel)
        self:flush()
    end

    for _ in confirm_mb:unpack() do
        builder:complete(datamodel)
        self:flush()
    end

    for _ in batch_construct_end_mb:unpack() do
        builder:laying_pipe_confirm(datamodel)
        self:flush()
    end

    for _ in construct_mb:unpack() do
        builder:construct(datamodel)
        self:flush()
    end

    for _ in teardown_mb:unpack() do
        builder:teardown(datamodel)
        self:flush()
    end

    for _ in batch_teardown_begin_mb:unpack() do
        builder:batch_teardown_begin(datamodel)
        self:flush()
    end
end

function M:stage_camera_usage(datamodel)
end

return M