local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local objects = require "objects"
local iui = ecs.require "engine.system.ui_system"

local move_mb = mailbox:sub {"move"}
local teardown_mb = mailbox:sub {"teardown"}
local copy_md = mailbox:sub {"copy"}

local M = {}
function M.create(object_id)
    iui.register_leave("/pkg/vaststars.resources/ui/building_menu_longpress.rml")

    local object = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName(object.prototype_name)
    assert(typeobject.move ~= false or typeobject.teardown ~= false)

    local datamodel = {
        prototype_name = object.prototype_name,
        move = typeobject.move ~= false,
        teardown = typeobject.teardown ~= false,
        copy = true,
        object_id = object_id,
    }

    return datamodel
end

function M.update(datamodel, object_id)
    for _ in move_mb:unpack() do
        iui.leave()
        iui.redirect("/pkg/vaststars.resources/ui/construct.rml", "move", object_id)
    end
    for _ in teardown_mb:unpack() do
        iui.redirect("/pkg/vaststars.resources/ui/construct.rml", "teardown", object_id)
    end
    for _ in copy_md:unpack() do
        local object = assert(objects:get(object_id))
        iui.redirect("/pkg/vaststars.resources/ui/construct.rml", "construct_entity", object.prototype_name)
    end
end

return M

