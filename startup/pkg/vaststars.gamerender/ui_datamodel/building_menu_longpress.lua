local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"
local iui = ecs.require "engine.system.ui_system"
local teardown_mb = mailbox:sub {"teardown"}

local M = {}
function M.create(gameplay_eid)
    iui.register_leave("/pkg/vaststars.resources/ui/building_menu_longpress.rml")

    local e = gameplay_core.get_entity(gameplay_eid)
    local typeobject = iprototype.queryById(e.building.prototype)

    local datamodel = {
        prototype_name = typeobject.name,
        teardown = typeobject.teardown ~= false,
        gameplay_eid = gameplay_eid,
    }

    return datamodel
end

function M.update(datamodel, gameplay_eid)
    for _ in teardown_mb:unpack() do
        iui.redirect("/pkg/vaststars.resources/ui/construct.rml", "teardown", gameplay_eid)
    end
end

return M

