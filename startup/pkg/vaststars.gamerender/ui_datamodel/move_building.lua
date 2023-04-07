local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.gamerender|iui"
local mu = import_package "ant.math".util
local math3d = require "math3d"

local cancel_mb = mailbox:sub {"cancel"}
local build_mb = mailbox:sub {"build"}
local show_confirm_mb = mailbox:sub {"show_confirm"}

---------------
local M = {}

function M:create(position)
    local mq = w:first("main_queue camera_ref:in render_target:in")
    local ce <close> = w:entity(mq.camera_ref, "camera:in")
    local vp = ce.camera.viewprojmat
    local vr = mq.render_target.view_rect
    local p = mu.world_to_screen(vp, vr, position)
    local ui_x, ui_y = iui.convert_coord(vr, math3d.index(p, 1), math3d.index(p, 2))

    return {
        show_cancel  = true,
        show_confirm = true,
        left = ui_x,
        top = ui_y,
        x = position[1],
        y = position[3],
    }
end

function M:stage_ui_update(datamodel)
    for _ in cancel_mb:unpack() do
        iui.redirect("construct.rml", "move_finish")
    end

    for _ in build_mb:unpack() do
        iui.redirect("construct.rml", "build")
    end

    for _, _, _, b in show_confirm_mb:unpack() do
        datamodel.show_confirm = b
    end
end

return M