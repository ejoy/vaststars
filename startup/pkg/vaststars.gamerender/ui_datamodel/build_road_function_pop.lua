local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.gamerender|iui"
local create_roadbuilder = ecs.require "editor.build_road"
local iprototype = require "gameplay.interface.prototype"
local dragdrop_camera_mb = world:sub {"dragdrop_camera"}
local single_touch_mb = world:sub {"single_touch"}

local construct_begin_mb = mailbox:sub {"construct_begin"}
local construct_end_mb = mailbox:sub {"construct_end"}
local cancel_mb = mailbox:sub {"cancel"}
local leave_mb = mailbox:sub {"leave"}

local builder

---------------
local M = {}
function M:create(position, ui_x, ui_y, x, y)
    return {
        position = position,
        left = ui_x,
        top = ui_y,
        x = x,
        y = y,
        show_laying_road_begin = true,
        show_laying_road_end = false,
        show_laying_road_cancel = true,
    }
end

function M:stage_ui_update(datamodel)
    for _, _, _, x, y in construct_begin_mb:unpack() do
        datamodel.show_laying_road_begin = false

        if builder then
            builder:clean(datamodel)
        end
        builder = assert(create_roadbuilder())
        local typeobject = iprototype.queryByName("entity", "砖石公路-X型-01")
        builder:new_entity(datamodel, typeobject, x, y)
        if datamodel.show_laying_road_begin then
            builder:laying_pipe_begin(datamodel)
            datamodel.state = "begin"
        end
    end

    for _ in construct_end_mb:unpack() do
        assert(builder)
        builder:laying_pipe_confirm(datamodel)
        builder:complete(datamodel)
        iui.close("build_road_function_pop.rml")
    end

    for _ in cancel_mb:unpack() do
        if builder then
            builder:laying_pipe_cancel(datamodel)
            builder:clean(datamodel)
        end
        iui.close("build_road_function_pop.rml")
    end

    for _, delta in dragdrop_camera_mb:unpack() do
        if builder then
            builder:touch_move(datamodel, delta)
            self:flush()
        end
    end

    for _, state in single_touch_mb:unpack() do
        if state == "END" or state == "CANCEL" then
            if builder then
                local succ = builder:touch_end(datamodel)
                if succ then
                    datamodel.show_laying_road_end = true
                end
                self:flush()
            end
        end
    end

    for _ in leave_mb:unpack() do
        if builder then
            builder:clean(datamodel)
        end
    end

end

return M