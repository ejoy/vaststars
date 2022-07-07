local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local set_recipe_mb = mailbox:sub {"set_recipe"}
local click_category_mb = mailbox:sub {"click_category"}
local click_recipe_mb = mailbox:sub {"click_recipe"}
local recipe_category_cfg = import_package "vaststars.prototype"("recipe_category")
local irecipe = require "gameplay.interface.recipe"
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iworld = require "gameplay.interface.world"
local clear_recipe_mb = mailbox:sub {"clear_recipe"}
local objects = require "objects"
local ieditor = ecs.require "editor.editor"
local ifluid = require "gameplay.interface.fluid"
local iassembling = require "gameplay.interface.assembling"
local terrain = ecs.require "terrain"

-- TODO: optimize
local recipes = {} ; local get_recipe_index; do
    local t = {}
    for _, v in pairs(iprototype.each_maintype "recipe") do
        t[v.category] = t[v.category] or {}
        t[v.category][#t[v.category] + 1] = {
            name = v.name,
            order = v.order,
            icon = v.icon,
            time = v.time,
            ingredients = irecipe.get_elements(v.ingredients),
            results = irecipe.get_elements(v.results),
            group = v.group,
            category = v.category,
        }
    end

    for _, group in ipairs(recipe_category_cfg) do
        for _, category in ipairs(group.category) do
            assert(t[category], ("recipe category `%s` not found in recipe_category_cfg"):format(category))
            for _, recipe_item in ipairs(t[category]) do
                if recipe_item.group == group.group then
                    recipes[group.group] = recipes[group.group] or {}
                    recipes[group.group][#recipes[group.group] + 1] = recipe_item
                end
            end
        end
    end

    for _, v in pairs(recipes) do
        table.sort(v, function(a, b)
            return a.order < b.order
        end)
    end

    -- TODO: optimize
    local function _get_category_index(category)
        for index, group in ipairs(recipe_category_cfg) do
            for _, c in ipairs(group.category) do
                if c == category then
                    return index
                end
            end
        end
    end

    --
    local cache = {}
    for _, c in pairs(recipes) do
        for index, recipe in ipairs(c) do
            cache[recipe.name] = {_get_category_index(recipe.category), index}
        end
    end
    function get_recipe_index(name)
        return table.unpack(cache[name])
    end
end

local recipe_locked; do
    local recipe_tech = {}
    for _, typeobject in pairs(iprototype.each_maintype "tech") do
        if typeobject.effects and typeobject.effects.unlock_recipe then
            for _, recipe in ipairs(typeobject.effects.unlock_recipe) do
                assert(not recipe_tech[recipe])
                recipe_tech[recipe] = typeobject.name
            end
        end
    end

    function recipe_locked(recipe)
        local tech = recipe_tech[recipe]
        if not tech then
            log.info(("recipe `%s` is unlocked defaultly"):format(recipe))
            return true
        end
        return gameplay_core.is_researched(tech)
    end
end

-- TODO：duplicate code with builder.lua
local function _update_recipe_items_fluidbox(object)
    local function is_connection(x1, y1, dir1, x2, y2, dir2)
        local succ, dx1, dy1, dx2, dy2
        succ, dx1, dy1 = terrain:move_coord(x1, y1, dir1, 1)
        if not succ then
            return false
        end
        succ, dx2, dy2 = terrain:move_coord(x2, y2, dir2, 1)
        if not succ then
            return false
        end
        return (dx1 == x2 and dy1 == y2) and (dx2 == x1 and dy2 == y1)
    end

    for _, fb in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) do
        local succ, neighbor_x, neighbor_y = terrain:move_coord(fb.x, fb.y, fb.dir, 1)
        if not succ then
            goto continue
        end
        local neighbor = objects:coord(neighbor_x, neighbor_y)
        if not neighbor then
            goto continue
        end
        local typeobject = iprototype.queryByName("entity", neighbor.prototype_name)
        if not iprototype.has_type(typeobject.type, "fluidbox") then
            goto continue
        end
        assert(type(neighbor.fluid_name) == "string") -- TODO：fluid_name should be string -- remove this assert
        for _, neighbor_fb in ipairs(ifluid:get_fluidbox(neighbor.prototype_name, neighbor_x, neighbor_y, neighbor.dir, neighbor.fluid_name)) do
            if is_connection(fb.x, fb.y, fb.dir, neighbor_fb.x, neighbor_fb.y, neighbor_fb.dir) then
                if neighbor_fb.fluid_name == "" then
                    for _, sibling in objects:selectall("fluidflow_id", neighbor.fluidflow_id, {"CONSTRUCTED"}) do
                        sibling.fluid_name = fb.fluid_name
                        ifluid:update_fluidbox(gameplay_core.get_entity(sibling.gameplay_eid), sibling.fluid_name)
                    end
                else
                    if neighbor.fluid_name ~= fb.fluid_name then
                        local prototype_name, dir = ieditor:refresh_pipe(neighbor.prototype_name, neighbor.dir, neighbor_fb.dir, 0)
                        if prototype_name and dir and (prototype_name ~= neighbor.prototype_name or dir ~= neighbor.dir) then
                            neighbor.prototype_name = prototype_name
                            neighbor.dir = dir
                        end
                    end
                end
                break -- should only have one fluidbox connected
            end
        end
        ::continue::
    end
    gameplay_core.build()
end

local function _show_object_recipe(datamodel, object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end

    datamodel.object_id = object_id
    datamodel.recipe_name = ""
    datamodel.catalog_index = 1
    datamodel.recipe_index = 1 -- recipe_index is the index of recipe_items[caterory], default is 1

    if e.assembling.recipe ~= 0 then
        datamodel.recipe_name = iprototype.queryById(e.assembling.recipe).name
        datamodel.catalog_index, datamodel.recipe_index = get_recipe_index(datamodel.recipe_name)
    end
end

local function _update_recipe_items(datamodel)
    local storage = gameplay_core.get_storage()
    storage.recipe_new_flag = storage.recipe_new_flag or {}

    datamodel.recipe_items = {}
    local recipe_category_new_flag = {}
    for name, group in pairs(recipes) do
        for _, recipe_item in ipairs(group) do
            if recipe_locked(recipe_item.name) then
                if name == recipe_category_cfg[datamodel.catalog_index].group then
                    datamodel.recipe_items[#datamodel.recipe_items+1] = {
                        name = recipe_item.name,
                        order = recipe_item.order,
                        icon = recipe_item.icon,
                        time = recipe_item.time,
                        ingredients = recipe_item.ingredients,
                        results = recipe_item.results,
                        group = recipe_item.group,
                        new = (not storage.recipe_new_flag[recipe_item.name]) and true or false,
                    }
                end
                if not storage.recipe_new_flag[recipe_item.name] then
                    recipe_category_new_flag[recipe_item.group] = true
                end
            end
        end
    end

    datamodel.recipe_category = {}
    for _, category in ipairs(recipe_category_cfg) do
        datamodel.recipe_category[#datamodel.recipe_category+1] = {
            group = category.group,
            icon = category.icon,
            new = recipe_category_new_flag[category.group] and true or false,
        }
    end
end

---------------
local M = {}

function M:create(object_id)
    local datamodel = {}
    _show_object_recipe(datamodel, object_id)
    _update_recipe_items(datamodel)
    return datamodel
end

function M:stage_ui_update(datamodel, object_id)
    for _, _, _, category_id in click_category_mb:unpack() do
        datamodel.catalog_index = category_id
        datamodel.recipe_index = 1 -- recipe_index is the index of recipe_items[caterory], default is 1
        _update_recipe_items(datamodel)
    end

    for _, _, _, recipe_name in click_recipe_mb:unpack() do
        local storage = gameplay_core.get_storage()
        storage.recipe_new_flag = storage.recipe_new_flag or {}
        storage.recipe_new_flag[recipe_name] = true
        _update_recipe_items(datamodel)
    end

    for _, _, _, object_id, recipe_name in set_recipe_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        if e.assembling then
            -- get all of assembling's items before set new recipe
            local item_counts = {}
            local e = gameplay_core.get_entity(object.gameplay_eid)
            if e.assembling then
                for prototype_name, count in pairs(iassembling.item_counts(gameplay_core.get_world(), e)) do
                    local typeobject_item = iprototype.queryByName("item", prototype_name)
                    if not typeobject_item then
                        log.error(("can not found item `%s`"):format(prototype_name))
                    else
                        item_counts[typeobject_item.id] = item_counts[typeobject_item.id] or 0
                        item_counts[typeobject_item.id] = item_counts[typeobject_item.id] + count
                    end
                end
            end

            if iworld:set_recipe(gameplay_core.get_world(), e, recipe_name) then
                local headquater_e = iworld:get_headquater_entity(gameplay_core.get_world())
                if headquater_e then
                    for prototype, count in pairs(item_counts) do
                        if not gameplay_core.get_world():container_place(headquater_e.chest.container, prototype, count) then
                            log.error(("failed to place `%s` `%s`"):format(prototype, count))
                        end
                    end
                else
                    log.error("no headquater")
                end

                gameplay_core.build()

                -- TODO viewport
                local recipe_typeobject = iprototype.queryByName("recipe", recipe_name)
                assert(recipe_typeobject, ("can not found recipe `%s`"):format(recipe_name))
                object.fluid_name = irecipe.get_init_fluids(recipe_typeobject) or {} -- recipe may not have fluid

                _update_recipe_items_fluidbox(object)
                gameplay_core.build()

                iui.update("assemble_2.rml", "update", object_id)
                iui.update("build_function_pop.rml", "update", object_id)
            end
        else
            log.error(("can not found assembling `%s`(%s, %s)"):format(object.name, object.x, object.y))
        end
    end

    for _ in clear_recipe_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        iworld:set_recipe(gameplay_core.get_world(), e, nil)
        object.fluid_name = {}

        _update_recipe_items_fluidbox(object)
        gameplay_core.build()
    end
end

return M