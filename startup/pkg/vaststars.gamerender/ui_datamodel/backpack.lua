local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local ibackpack = require "gameplay.interface.backpack"
local click_item_mb = mailbox:sub {"click_item"}
local iui = ecs.require "engine.system.ui_system"

local function get_items()
    local t = {}
    local gameplay_world = gameplay_core.get_world()
    local base = ibackpack.get_base_entity(gameplay_world)
    for _, slot in pairs(ibackpack.all(gameplay_world, base)) do
        local typeobject_item = assert(iprototype.queryById(slot.item))

        local v = {}
        v.id = typeobject_item.id
        v.name = typeobject_item.name
        v.icon = typeobject_item.item_icon
        v.count = slot.amount
        v.order = typeobject_item.item_order or 0
        t[#t+1] = v
    end

    for _, items in pairs(t) do
        table.sort(items, function (a, b)
            return a.order < b.order
        end)
    end

    return t
end

---------------
local M = {}

function M.create()
    return {
        inventory = get_items(),
    }
end

function M.update(datamodel)
    for _, _, _, item in click_item_mb:unpack() do
        local typeobject = iprototype.queryById(item)
        if iprototype.has_type(typeobject.type, "building") then
            iui.close("/pkg/vaststars.resources/ui/backpack.html")
            local continuity = iprototype.continuity(typeobject)
            iui.redirect("/pkg/vaststars.resources/ui/construct.html", "construct_entity_from_backpack", item, continuity)
        end
    end
end

return M