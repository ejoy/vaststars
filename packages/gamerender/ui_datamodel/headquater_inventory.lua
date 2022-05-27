local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local global = require "global"
local cache_names = global.cache_names
local objects = global.objects
local item_category = import_package "vaststars.prototype"("item_category")
local gameplay_core = require "gameplay.core"
local ichest = require "gameplay.interface.chest"
local iprototype = require "gameplay.interface.prototype"
local iui = ecs.import.interface "vaststars.gamerender|iui"

local click_item_mb = mailbox:sub {"click_item"}

-- TODO
local function get_headquater_object()
    for _, object in objects:select("CONSTRUCTED", "headquater", true) do
        return object
    end
end

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
    local object = get_headquater_object()
    if object then
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        if e then
            -- 更新背包界面对应的道具
            local inventory = {}
            local item_counts = ichest:item_counts(gameplay_core.get_world(), e)
            for id, count in pairs(item_counts) do
                local typeobject_item = assert(iprototype:query(id))
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
            end

            datamodel.inventory = inventory
        end
    end

    for _, _, _, chest_object_id, prototype, count in click_item_mb:unpack() do
        local headquater_object = get_headquater_object()
        if not headquater_object then
            log.error("can not found headquater")
            goto continue
        end

        local headquater_e = gameplay_core.get_entity(assert(headquater_object.gameplay_eid))
        if not headquater_e then
            log.error("can not found headquater")
            goto continue
        end

        local chest_object = objects:get(cache_names, chest_object_id)
        if not chest_object then
            log.error(("can not found chest `%s`"):format(chest_object_id))
            goto continue
        end

        local chest_e = gameplay_core.get_entity(chest_object.gameplay_eid)
        if not chest_e then
            log.error(("can not found chest `%s`"):format(chest_object_id))
            goto continue
        end

        if not gameplay_core.get_world():container_pickup(headquater_e.chest.container, prototype, count) then
            log.error(("failed to pickup `%s` `%s`"):format(prototype, count))
        else
            if not gameplay_core.get_world():container_place(chest_e.chest.container, prototype, count) then
                log.error(("failed to place `%s` `%s`"):format(prototype, count))
            end
        end

        iui.update("cmdcenter.rml", "update")
        ::continue::
    end
end

return M