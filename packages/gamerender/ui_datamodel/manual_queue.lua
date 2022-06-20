local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local imanual = require "ui_datamodel.common.manual"
local cancel_mb = mailbox:sub {"cancel"}

local function get_ingredients()
    local t = {}
    for item, count in pairs(gameplay_core.get_world():manual_container()) do
        local item_typeobject = iprototype.queryByName("item", item)
        t[#t+1] = {name = item_typeobject.name, count = count, icon = item_typeobject.icon}
    end
    return t
end

local M = {}
function M:create()
    return {
        queue = imanual.get_queue(),
        ingredients = get_ingredients(),
    }
end

function M:stage_ui_update(datamodel)
    for _, _, _, index in cancel_mb:unpack() do
        imanual.cancel(index)
    end

    datamodel.queue = imanual.get_queue()
    datamodel.ingredients = get_ingredients()
end

return M