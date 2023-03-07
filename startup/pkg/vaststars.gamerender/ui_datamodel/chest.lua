local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local math3d    = require "math3d"
local ivs       = ecs.import.interface "ant.scene|ivisible_state"
local iUiRt     = ecs.import.interface "ant.rmlui|iuirt"
local iom       = ecs.import.interface "ant.objcontroller|iobj_motion"
local item_category = import_package "vaststars.prototype"("item_category")
local gameplay_core = require "gameplay.core"
local ichest = require "gameplay.interface.chest"
local iprototype = require "gameplay.interface.prototype"
local itypes = require "gameplay.interface.types"
local objects = require "objects"
local irecipe = require "gameplay.interface.recipe"
local click_item_mb = mailbox:sub {"click_item"}

local mt = {}
function mt:__index(k)
    self[k] = {}
    return self[k]
end
local item_crafting_recipe = setmetatable({}, mt)   -- item id -> crafting recipe info
local item_crafting_entities = setmetatable({}, mt) -- item id -> crafting entity info
local category_to_entities = setmetatable({}, mt)

for _, typeobject in pairs(iprototype.each_maintype("item")) do
    assert(typeobject.group, "item group is nil: " .. typeobject.name)
end

for _, typeobject in pairs(iprototype.each_maintype("building", "assembling")) do
    if typeobject.recipe then -- default recipe
        local typeobject_recipe = assert(iprototype.queryByName(typeobject.recipe))
        category_to_entities[typeobject_recipe.category][typeobject.id] = {icon = typeobject.icon, name = typeobject.name}
    else
        if not typeobject.craft_category then
            if not typeobject.mining_category then
                log.error(("%s dont have craft_category"):format(typeobject.name))
            end
        else
            for _, craft_category in ipairs(typeobject.craft_category) do
                category_to_entities[craft_category][typeobject.id] = {icon = typeobject.icon, name = typeobject.name}
            end
        end
    end
end

local function _has_type(prototype, type)
    local typeobject = assert(iprototype.queryById(prototype))
    return iprototype.has_type(typeobject.type, type)
end

for _, typeobject in pairs(iprototype.each_maintype("recipe")) do
    for idx, element in ipairs(itypes.items(typeobject.results)) do
        if not _has_type(element.id, "item") then
            goto continue
        end

        local id = element.id
        table.insert(item_crafting_recipe[id], {
            icon = assert(typeobject.recipe_icon),
            element = irecipe.get_elements(typeobject.ingredients),
            time = itypes.time(typeobject.time),
            weight = idx, -- display the first result first
            recipe_name = typeobject.name, -- for debug
        })

        for entity_prototype, v in pairs(category_to_entities[typeobject.category]) do
            item_crafting_entities[id][entity_prototype] = v
        end
        ::continue::
    end
end

local function _limit(list, top)
    table.sort(list, function(a, b) return a.weight < b.weight end)
    local result = {}
    table.move(list, 1, top, 1, result)
    return result
end

for idx, item_info in pairs(item_crafting_recipe) do
    item_crafting_recipe[idx] = _limit(item_info, 5)
end

for id, entity_info in pairs(item_crafting_entities) do
    local result = {}
    local c = 0
    for _, v in pairs(entity_info) do -- TODO: display all entities
        table.insert(result, v)
        c = c + 1
        if c >= 4 then
            break
        end
    end
    item_crafting_entities[id] = result
end

local function get_inventory(object_id)
    local inventory = {}
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return inventory
    end

    for _, slot in pairs(ichest.collect_item(gameplay_core.get_world(), e)) do
        if slot.item == 0 then -- TODO: fix this
            goto continue
        end
        local typeobject_item = assert(iprototype.queryById(slot.item))
        local stack = slot.amount

        while stack > 0 do
            local t = {}
            t.id = typeobject_item.id
            t.name = typeobject_item.name
            t.icon = typeobject_item.icon
            t.category = typeobject_item.group[1] -- currently, items will only have one category, which is used for displaying in the inventory.

            if stack >= typeobject_item.stack then
                t.count = typeobject_item.stack
            else
                t.count = stack
            end

            inventory[#inventory+1] = t
            stack = stack - typeobject_item.stack
        end
        ::continue::
    end
    return inventory
end

local function update(datamodel, object_id)
    datamodel.inventory = get_inventory(object_id)
end

---------------
local M = {}
local current_model
local model_path
function M:create(object_id)
    local object = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName(object.prototype_name)
    model_path = typeobject.model
    if current_model then
        for _, eid in ipairs(current_model.tag["*"]) do
            w:remove(eid)
        end
        current_model = nil
    end
    return {
        object_id = object_id, -- for update
        prototype_name = iprototype.show_prototype_name(typeobject),
        item_category = item_category,
        inventory = get_inventory(object_id),
        item_prototype_name = "",
        max_slot_count = typeobject.slots,
    }
end
local queuename = "chest_model_queue"
local gid
local inited = false
function M:stage_ui_update(datamodel)
    gid = iUiRt.get_group_id("chest_model")
    if gid and not inited then
        inited = true
        local g = ecs.group(gid)
        g:enable "view_visible"
        g:enable "scene_update"
        -- g:create_instance("/pkg/vaststars.resources/light2.prefab")
        -- local ground = g:create_instance("/pkg/ant.resources.binary/meshes/plane.glb|mesh.prefab")
        -- ground.on_ready = function (e)
        --     for _, eid in ipairs(e.tag['*']) do
        --         local ee = w:entity(eid, "visible_state?in")
        --         if ee.visible_state then
        --             ivs.set_state(ee, "main_view|selectable|cast_shadow", false)
        --             ivs.set_state(ee, queuename, true)
        --         end
        --     end
        -- end
        -- world:create_object(ground)
        local test = g:create_instance("/pkg/vaststars.resources/prefabs/drone.prefab")--g:create_instance("/pkg/vaststars.resources/"..model_path)--
        test.on_ready = function (e)
            for _, eid in ipairs(e.tag['*']) do
                local ee = w:entity(eid, "visible_state?in")
                if ee.visible_state then
                    ivs.set_state(ee, "main_view|selectable|cast_shadow", false)
                    ivs.set_state(ee, queuename, true)
                    -- iom.set_position(ee, math3d.vector(0, 0, 0))
                end
            end 
        end       
        world:create_object(test)
    end
    -- if gid and model_path and not current_model then
    --     local g = ecs.group(gid)
    --     --TODO: test model
    --     current_model = g:create_instance("/pkg/vaststars.resources/prefabs/drone.prefab")--g:create_instance("/pkg/vaststars.resources/"..model_path)--
    --     current_model.on_ready = function (e)
    --         for _, eid in ipairs(e.tag['*']) do
    --             local ee = w:entity(eid, "visible_state?in")
    --             if ee.visible_state then
    --                 ivs.set_state(ee, "main_view|selectable|cast_shadow", false)
    --                 ivs.set_state(ee, queuename, true)
    --                 -- iom.set_position(ee, math3d.vector(0, 0, 0))
    --             end
    --         end 
    --     end       
    --     world:create_object(current_model)
    -- end

    for _, _, _, prototype in click_item_mb:unpack() do
        local typeobject = iprototype.queryById(prototype)
        datamodel.show_item_info = true
        datamodel.item_prototype_name = iprototype.show_prototype_name(typeobject)
        datamodel.item_info = item_crafting_recipe[tonumber(prototype)] or {}
        datamodel.entities = item_crafting_entities[tonumber(prototype)] or {}
        self:flush()
    end

    update(datamodel, datamodel.object_id) -- TODO
    self:flush()
end

function M:update(datamodel)
    update(datamodel, datamodel.object_id)
    self:flush()
end

return M