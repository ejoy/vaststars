local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local create_roadbuilder = ecs.require "editor.roadbuilder"
local iprototype = require "gameplay.interface.prototype"
local single_touch_mb = world:sub {"single_touch"}
local dragdrop_camera_mb = world:sub {"dragdrop_camera"}
local start_laying_mb = mailbox:sub {"start_laying"}
local finish_laying_mb = mailbox:sub {"finish_laying"}
local place_one_mb = mailbox:sub {"place_one"}
local cancel_mb = mailbox:sub {"cancel"}
local confirm_mb = mailbox:sub {"confirm"}
local remove_one_mb = mailbox:sub {"remove_one"}
local start_teardown_mb = mailbox:sub {"start_teardown"}
local finish_teardown_mb = mailbox:sub {"finish_teardown"}
local back_mb = mailbox:sub {"back"}

---------------
local M = {}
local builder

function M:create()
    local datamodel = {
        show_confirm = false,
        show_start_teardown = false,
        start_laying = false,
        show_place_one = false,
        show_remove_one = false,
        show_finish_teardown = false,
        show_finish_laying = false,
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

    for _ in start_laying_mb:unpack() do
        builder:start_laying(datamodel)
        self:flush()
    end

    for _ in cancel_mb:unpack() do
        builder:cancel(datamodel)
        self:flush()
    end

    for _ in confirm_mb:unpack() do
        builder:confirm(datamodel)
        self:flush()
    end

    for _ in finish_laying_mb:unpack() do
        builder:finish_laying(datamodel)
        self:flush()
    end

    for _ in place_one_mb:unpack() do
        builder:place_one(datamodel)
        self:flush()
    end

    for _ in remove_one_mb:unpack() do
        builder:remove_one(datamodel)
        self:flush()
    end

    for _ in start_teardown_mb:unpack() do
        builder:start_teardown(datamodel)
        self:flush()
    end

    for _ in finish_teardown_mb:unpack() do
        builder:finish_teardown(datamodel)
        self:flush()
    end

    for _ in back_mb:unpack() do
        builder:back(datamodel)
        self:flush()
    end
end

function M:stage_camera_usage(datamodel)
end

return M