local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.gamerender|iui"
local math3d = require "math3d"

local cancel_mb = mailbox:sub {"cancel"}
local build_mb = mailbox:sub {"build"}
local rotate_mb = mailbox:sub {"rotate"}
local show_confirm_mb = mailbox:sub {"show_confirm"}
local icamera_controller = ecs.interface "icamera_controller"
local iprototype = require "gameplay.interface.prototype"

---------------
local M = {}

function M:create(position, prototype_name)
    local p = icamera_controller.world_to_screen(position)
    local ui_x, ui_y = iui.convert_coord(math3d.index(p, 1), math3d.index(p, 2))
    local typeobject = iprototype.queryByName(prototype_name)

    return {
        show_cancel  = true,
        show_confirm = true,
        show_rotate = (typeobject.rotate_on_build == true),
        left = ui_x,
        top = ui_y,
        x = position[1],
        y = position[3],
    }
end

function M:stage_ui_update(datamodel)
    for _ in cancel_mb:unpack() do
        iui.redirect("construct.rml", "cancel")
    end

    for _ in build_mb:unpack() do
        iui.redirect("construct.rml", "build")
    end

    for _ in rotate_mb:unpack() do
        iui.redirect("construct.rml", "rotate")
    end

    for _, _, _, b in show_confirm_mb:unpack() do
        datamodel.show_confirm = b
    end
end

return M