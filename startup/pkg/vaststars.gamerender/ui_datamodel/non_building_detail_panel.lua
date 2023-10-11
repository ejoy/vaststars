local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iui = ecs.require "engine.system.ui_system"
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local interval_call = ecs.require "engine.interval_call"

local M = {}

function M.create(icon, name, gameplay_eid)
    iui.register_leave("/pkg/vaststars.resources/ui/non_building_detail_panel.rml")

    local item_icon = ""
    local item_name = ""
    if gameplay_eid then
        local e = gameplay_core.get_entity(gameplay_eid)
        if e.lorry then
            if e.lorry.item_prototype ~= 0 and e.lorry.item_amount > 0 then
                local typeobject = iprototype.queryById(e.lorry.item_prototype)
                item_icon = typeobject.icon
                item_name = typeobject.name
            end
        end
    end

    return {
        icon = icon,
        prototype_name = name,
        item_icon = item_icon,
        item_name = item_name,
    }
end


local updateLorryIcon = interval_call(300, function(datamodel, gameplay_eid)
    if gameplay_eid then
        local e = gameplay_core.get_entity(gameplay_eid)
        if e.lorry then
            if e.lorry.item_prototype ~= 0 and e.lorry.item_amount > 0 then
                local typeobject = iprototype.queryById(e.lorry.item_prototype)
                datamodel.item_icon = typeobject.item_icon
                datamodel.item_name = iprototype.display_name(typeobject)
            else
                datamodel.item_icon = ""
                datamodel.item_name = ""
            end
        end
    end
end)

function M.update(datamodel, icon, name, gameplay_eid)
    updateLorryIcon(datamodel, gameplay_eid)
end

return M