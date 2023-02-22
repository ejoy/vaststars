local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local ilaboratory = require "gameplay.interface.laboratory"
local ichest = require "gameplay.interface.chest"

local objects = require "objects"
local open_techui_mb = mailbox:sub {"open_techui"}
local M = {}
local current_inputs
local inputs_count
local current_e
function M:create(object_id)
    local object = assert(objects:get(object_id))
    current_e = gameplay_core.get_entity(assert(object.gameplay_eid))
    local typeobject = iprototype.queryByName("building", object.prototype_name)
    current_inputs = ilaboratory:get_elements(typeobject.inputs)
    local items = {}
    for i, value in ipairs(current_inputs) do
        local slot = ichest.chest_get(gameplay_core.get_world(), current_e.chest, i)
        items[#items+1] = {name = value.name, icon = value.icon, stack = value.stack, count = slot.amount or 0}
    end
    inputs_count = #current_inputs
    return {
        object_id = object_id,
        prototype_name = object.prototype_name,
        background = "textures/build_background/pic_lab.texture",
        items = items,
    }
end

function M:stage_ui_update(datamodel)
    --tech.process
    for i = 1, inputs_count do
        local slot = ichest.chest_get(gameplay_core.get_world(), current_e.chest, i)
        if slot then
            datamodel.items[i].count = slot.amount
        end
    end
    datamodel.items = datamodel.items

    for _, _, _ in open_techui_mb:unpack() do
        gameplay_core.world_update = false
    end
end

return M