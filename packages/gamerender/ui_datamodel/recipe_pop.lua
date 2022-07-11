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

-- prototype.recipe_category.group -> the category of ui
local recipes = {} ; local get_recipe_index; do
    for _, v in pairs(iprototype.each_maintype "recipe") do
        if v.group then -- if group is not nil, need to add to the category of ui
            recipes[v.group] = recipes[v.group] or {}
            recipes[v.group][#recipes[v.group] + 1] = {
                name = v.name,
                order = v.order,
                icon = v.icon,
                time = v.time,
                ingredients = irecipe.get_elements(v.ingredients),
                results = irecipe.get_elements(v.results),
                group = v.group,
            }
        end
    end

    for _, v in pairs(recipes) do
        table.sort(v, function(a, b)
            return a.order < b.order
        end)
    end

    local function _get_group_index(group)
        for index, category_set in ipairs(recipe_category_cfg) do
            if category_set.group == group then
                return index
            end
        end
        assert(false, ("group `%s` not found"):format(group))
    end

    --
    local cache = {}
    for _, c in pairs(recipes) do
        for index, recipe in ipairs(c) do
            cache[recipe.name] = {_get_group_index(recipe.group), index}
        end
    end
    -- recipe_name -> {category_index, recipe_index}
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
            log.info(("recipe `%s` is locked defaultly"):format(recipe))
            return false
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

local function _update_recipe_items(datamodel, recipe_name)
    local storage = gameplay_core.get_storage()
    storage.recipe_new_flag = storage.recipe_new_flag or {}

    local cur_recipe_category_cfg = assert(recipe_category_cfg[datamodel.catalog_index])
    assert(recipes[cur_recipe_category_cfg.group][1])
    if not recipe_name then
        for _, recipe in ipairs(recipes[cur_recipe_category_cfg.group]) do
            if recipe_locked(recipe.name) then
                recipe_name = recipe.name
                break
            end
        end
    end
    -- if recipe_name is nil, it means all recipes are locked

    datamodel.recipe_items = {}
    local recipe_category_new_flag = {}
    for group, recipe_set in pairs(recipes) do
        for _, recipe_item in ipairs(recipe_set) do
            if recipe_locked(recipe_item.name) then
                if group == cur_recipe_category_cfg.group then
                    datamodel.recipe_items[#datamodel.recipe_items+1] = {
                        name = recipe_item.name,
                        icon = recipe_item.icon,
                        time = recipe_item.time,
                        ingredients = recipe_item.ingredients,
                        results = recipe_item.results,
                        new = (not storage.recipe_new_flag[recipe_item.name]) and true or false,
                    }
                end

                if recipe_name and recipe_name == recipe_item.name then
                    datamodel.recipe_name = recipe_item.name
                    datamodel.recipe_ingredients = recipe_item.ingredients
                    datamodel.recipe_results = recipe_item.results
                    datamodel.recipe_time = itypes.time(recipe_item.time)
                end

                if not storage.recipe_new_flag[group] then
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