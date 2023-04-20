local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.gamerender|iui"
local mu = import_package "ant.math".util
local math3d = require "math3d"

local rotate_mb = mailbox:sub {"rotate"}
local cancel_mb = mailbox:sub {"cancel"}
local build_mb = mailbox:sub {"build"}
local guide_on_going_mb = mailbox:sub {"guide_on_going"}
local iprototype = require "gameplay.interface.prototype"

---------------
local M = {}

function M:create(position, prototype_name)
    local mq = w:first("main_queue camera_ref:in render_target:in")
    local ce <close> = w:entity(mq.camera_ref, "camera:in")
    local vp = ce.camera.viewprojmat
    local vr = mq.render_target.view_rect
    local p = mu.world_to_screen(vp, vr, position)
    local ui_x, ui_y = iui.convert_coord(vr, math3d.index(p, 1), math3d.index(p, 2))
    local typeobject = iprototype.queryByName(prototype_name)

    return {
        show_rotate  = (typeobject.rotate_on_build == true),
        show_cancel  = true,
        show_confirm = true,
        left = ui_x,
        top = ui_y,
        x = position[1],
        y = position[3],
    }
end

function M:stage_ui_update(datamodel)
    for _ in rotate_mb:unpack() do
        iui.redirect("construct.rml", "rotate")
    end

    for _ in cancel_mb:unpack() do
        iui.redirect("construct.rml", "cancel")
    end

    for _ in build_mb:unpack() do
        iui.redirect("construct.rml", "build")
    end

    for _ in guide_on_going_mb:unpack() do
        iui.redirect("construct.rml", "cancel")
    end
end

return M