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
local itypes = require "gameplay.interface.types"
local recipe_unlocked = ecs.require "ui_datamodel.common.recipe_unlocked".recipe_unlocked
local iflow_connector = require "gameplay.interface.flow_connector"

local assembling_recipe = {}; local get_recipe_index; do
    local cache = {}
    for _, v in pairs(iprototype.each_maintype "recipe") do
        if v.group then
            local recipe_item = {
                name = v.name,
                order = v.order,
                icon = v.icon,
                time = v.time,
                ingredients = irecipe.get_elements(v.ingredients),
                results = irecipe.get_elements(v.results),
                group = v.group,
            }
            cache[v.category] = cache[v.category] or {}
            cache[v.category][#cache[v.category] + 1] = recipe_item
        end
    end

    local function _get_group_index(group)
        for index, category_set in ipairs(recipe_category_cfg) do
            if category_set.group == group then
                return index
            end
        end
        assert(false, ("group `%s` not found"):format(group))
    end

    local index_cache = {}

    for _, v in pairs(iprototype.each_maintype "entity") do
        if not (iprototype.has_type(v.type, "assembling") and v.craft_category )then
            goto continue
        end

        if iprototype.has_type(v.type, "mining") then -- TODO: special case for mining
            goto continue
        end

        assembling_recipe[v.name] = assembling_recipe[v.name] or {}

        for _, c in ipairs(v.craft_category) do
            assert(cache[c], ("can not find category `%s`"):format(c))
            for _, recipe_item in ipairs(cache[c]) do
                assembling_recipe[v.name][recipe_item.group] = assembling_recipe[v.name][recipe_item.group] or {}
                assembling_recipe[v.name][recipe_item.group][#assembling_recipe[v.name][recipe_item.group] + 1] = recipe_item
            end
        end
        for _, v in pairs(assembling_recipe[v.name]) do
            table.sort(v, function(a, b)
                return a.order < b.order
            end)
        end

        --
        for _, g in pairs(assembling_recipe[v.name]) do
            for index, recipe in ipairs(g) do
                index_cache[v.name] = index_cache[v.name] or {}
                index_cache[v.name][recipe.name] = {_get_group_index(recipe.group), index}
            end
        end
        -- recipe_name -> {category_index, recipe_index}
        function get_recipe_index(assembling_name, recipe_name)
            assert(index_cache[assembling_name], ("can not find assembling `%s`"):format(assembling_name))
            assert(index_cache[assembling_name][recipe_name], ("can not find recipe `%s`"):format(recipe_name))
            return table.unpack(index_cache[assembling_name][recipe_name])
        end

        ::continue::
    end
end

-- TODO：duplicate code with builder.lua
local function _update_neighbor_fluidbox(object)
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
        local prototype_name = iflow_connector.covers(neighbor.prototype_name, neighbor.dir)
        for _, neighbor_fb in ipairs(ifluid:get_fluidbox(prototype_name, neighbor_x, neighbor_y, neighbor.dir, neighbor.fluid_name)) do
            if is_connection(fb.x, fb.y, fb.dir, neighbor_fb.x, neighbor_fb.y, neighbor_fb.dir) then
                if neighbor_fb.fluid_name == "" then
                    for _, sibling in objects:selectall("fluidflow_id", neighbor.fluidflow_id, {"CONSTRUCTED"}) do
                        sibling.fluid_name = fb.fluid_name
                        ifluid:update_fluidbox(gameplay_core.get_entity(sibling.gameplay_eid), sibling.fluid_name)
                    end
                else
                    local prototype_name, dir
                    if neighbor.fluid_name ~= fb.fluid_name then
                        prototype_name, dir = ieditor:refresh_pipe(neighbor.prototype_name, neighbor.dir, neighbor_fb.dir, false)
                    else
                        prototype_name, dir = ieditor:refresh_pipe(neighbor.prototype_name, neighbor.dir, neighbor_fb.dir, true)
                    end
                    if prototype_name and dir and (prototype_name ~= neighbor.prototype_name or dir ~= neighbor.dir) then
                        neighbor.prototype_name = prototype_name
                        neighbor.dir = dir
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
        datamodel.catalog_index, datamodel.recipe_index = get_recipe_index(object.prototype_name, datamodel.recipe_name)
    end
end

local function _update_recipe_items(datamodel, recipe_name)
    local storage = gameplay_core.get_storage()
    storage.recipe_new_flag = storage.recipe_new_flag or {}

    local object = assert(objects:get(datamodel.object_id))
    local recipes = assembling_recipe[object.prototype_name]
    local cur_recipe_category_cfg = assert(recipe_category_cfg[datamodel.catalog_index])
    -- if recipe_name is nil, get the first unlocked recipe
    if not recipe_name then
        for _, recipe in ipairs(recipes[cur_recipe_category_cfg.group] or {}) do
            if recipe_unlocked(recipe.name) then
                recipe_name = recipe.name
                break
            end
        end
    end
    -- if recipe_name is nil, it means all recipes are locked or the category is empty
    if recipe_name then
        storage.recipe_new_flag = storage.recipe_new_flag or {}
        storage.recipe_new_flag[recipe_name] = true
    end

    datamodel.recipe_items = {}
    local recipe_category_new_flag = {}
    for group, recipe_set in pairs(recipes) do
        for _, recipe_item in ipairs(recipe_set) do
            if recipe_unlocked(recipe_item.name) then
                local new_recipe_flag = (not storage.recipe_new_flag[recipe_item.name]) and true or false

                if group == cur_recipe_category_cfg.group then
                    datamodel.recipe_items[#datamodel.recipe_items+1] = {
                        name = recipe_item.name,
                        icon = recipe_item.icon,
                        time = recipe_item.time,
                        ingredients = recipe_item.ingredients,
                        results = recipe_item.results,
                        new = new_recipe_flag,
                    }
                end

                if recipe_name and recipe_name == recipe_item.name then
                    datamodel.recipe_name = recipe_item.name
                    datamodel.recipe_ingredients = recipe_item.ingredients
                    datamodel.recipe_results = recipe_item.results
                    datamodel.recipe_time = itypes.time(recipe_item.time)
                end

                if new_recipe_flag then
                    recipe_category_new_flag[group] = true
                end
            end
        end
    end

    datamodel.recipe_category = {}
    for _, category in ipairs(recipe_category_cfg) do
        datamodel.recipe_category[#datamodel.recipe_category+1] = {
            group = category.group,
            icon = category.icon,
            new = recipe_category_new_flag[category.group] ~= nil and true or false,
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
        _update_recipe_items(datamodel, recipe_name)
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

                _update_neighbor_fluidbox(object)
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

        _update_neighbor_fluidbox(object)
        gameplay_core.build()
    end
end

return M