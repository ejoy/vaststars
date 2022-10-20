local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local objects = require "objects"
local item_category = import_package "vaststars.prototype"("item_category")
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iworld = require "gameplay.interface.world"

local click_item_mb = mailbox:sub {"click_item"}

----
local M = {}

function M:create(chest_object_id)
    return {
        chest_object_id = chest_object_id,
        item_category = item_category,
        inventory = {},
    }
end

function M:stage_ui_update(datamodel)
    local inventory = {}
    for id, count in pairs(iworld.base_chest(gameplay_core.get_world())) do
        local typeobject_item = assert(iprototype.queryById(id))
        local stack = count

        while stack > 0 do
            local t = {}
            t.id = typeobject_item.id
            t.name = typeobject_item.name
            t.icon = typeobject_item.icon
            t.category = typeobject_item.group

            if stack >= typeobject_item.stack then
                t.count = typeobject_item.stack
            else
                t.count = stack
            end

            inventory[#inventory+1] = t
            stack = stack - typeobject_item.stack
        end

        datamodel.inventory = inventory
    end

    for _, _, _, chest_object_id, prototype, count in click_item_mb:unpack() do
        local chest_object = objects:get(chest_object_id)
        if not chest_object then
            log.error(("can not found chest `%s`"):format(chest_object_id))
            goto continue
        end

        local chest_e = gameplay_core.get_entity(chest_object.gameplay_eid)
        if not chest_e then
            log.error(("can not found chest `%s`"):format(chest_object_id))
            goto continue
        end

        iworld.base_chest_pickup_place(gameplay_core.get_world(), chest_e.chest_2.chest_in, prototype, count, true)

        iui.update("chest.rml", "update")
        ::continue::
    end
end

return M