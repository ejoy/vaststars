local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local objects = require "objects"
local iui = ecs.import.interface "vaststars.gamerender|iui"

local move_mb = mailbox:sub {"move"}
local teardown_mb = mailbox:sub {"teardown"}
local copy_md = mailbox:sub {"copy"}

local M = {}
function M:create(object_id, object_position, ui_x, ui_y)
    local object = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName(object.prototype_name)
    assert(typeobject.move ~= false or typeobject.teardown ~= false)

    local datamodel = {
        move = typeobject.move ~= false,
        teardown = typeobject.teardown ~= false,
        copy = true,
        object_id = object_id,
        left = ui_x,
        top = ui_y,
        object_position = object_position,
    }

    return datamodel
end

function M:stage_ui_update(datamodel, object_id)
    for _ in move_mb:unpack() do
        iui.close("building_md_arc_menu.rml")
        iui.redirect("construct.rml", "move", object_id)
    end
    for _ in teardown_mb:unpack() do
        iui.redirect("construct.rml", "teardown", object_id)
    end
    for _ in copy_md:unpack() do
        local object = assert(objects:get(object_id))
        iui.redirect("construct.rml", "construct_entity", object.prototype_name)
    end
end

return M

