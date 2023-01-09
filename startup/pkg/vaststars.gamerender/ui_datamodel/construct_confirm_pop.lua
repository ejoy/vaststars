local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.gamerender|iui"
local mu = import_package "ant.math".util
local math3d = require "math3d"

local confirm_cancel_mb = mailbox:sub {"confirm_cancel"}

---------------
local M = {}

function M:create(position, x, y)
    local mq = w:first("main_queue camera_ref:in render_target:in")
    local ce <close> = w:entity(mq.camera_ref, "camera:in")
    local vp = ce.camera.viewprojmat
    local vr = mq.render_target.view_rect
    local p = mu.world_to_screen(vp, vr, position)
    local ui_x, ui_y = iui.convert_coord(vr, math3d.index(p, 1), math3d.index(p, 2))

    return {
        left = ui_x,
        top = ui_y,
        x = x,
        y = y,
    }
end

function M:stage_ui_update(datamodel)
    for msg in confirm_cancel_mb:each() do
        iui.redirect("construct.rml", table.unpack(msg, 3))
    end
end

return M