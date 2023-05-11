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
local terrain = ecs.require "terrain"
local itypes = require "gameplay.interface.types"
local recipe_unlocked = ecs.require "ui_datamodel.common.recipe_unlocked".recipe_unlocked
local iflow_connector = require "gameplay.interface.flow_connector"
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONSTRUCTED"}
local igameplay = ecs.import.interface "vaststars.gamerender|igameplay"
local itask = ecs.require "task"
local iprototype_cache = require "gameplay.prototype_cache.init"

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
        if not iprototype.is_pipe(neighbor.prototype_name) and not iprototype.is_pipe_to_ground(neighbor.prototype_name) then
            goto continue
        end
        assert(type(neighbor.fluid_name) == "string") -- TODO：fluid_name should be string -- remove this assert
        local prototype_name = iflow_connector.covers(neighbor.prototype_name, neighbor.dir)
        for _, neighbor_fb in ipairs(ifluid:get_fluidbox(prototype_name, neighbor_x, neighbor_y, neighbor.dir, neighbor.fluid_name)) do
            if is_connection(fb.x, fb.y, fb.dir, neighbor_fb.x, neighbor_fb.y, neighbor_fb.dir) then
                if neighbor_fb.fluid_name ~= "" then
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
    -- datamodel.recipe_name = ""
    datamodel.catalog_index = 1
    datamodel.recipe_index = 1 -- recipe_index is the index of recipe_items[caterory], default is 1

    if e.assembling.recipe ~= 0 then
        datamodel.recipe_name = iprototype.queryById(e.assembling.recipe).name
        -- datamodel.catalog_index, datamodel.recipe_index = get_recipe_index(object.prototype_name, datamodel.recipe_name)
    end
end

local function _update_recipe_items(datamodel, recipe_name)
    local storage = gameplay_core.get_storage()
    storage.recipe_picked_flag = storage.recipe_picked_flag or {}

    local object = assert(objects:get(datamodel.object_id))
    local recipes = iprototype_cache.get("recipe_pop")[object.prototype_name]
    local cur_recipe_category_cfg = assert(recipe_category_cfg[datamodel.catalog_index])
    -- if recipe_name is nil, get the first unlocked recipe
    if not recipe_name then
        for _, recipe in ipairs(recipes[cur_recipe_category_cfg.group] or {}) do
            if recipe_unlocked(recipe.name) then
                recipe_name = recipe.name
                datamodel.recipe_name = recipe_name
                break
            end
        end
    end
    -- if recipe_name is nil, it means all recipes are locked or the category is empty
    if recipe_name then
        storage.recipe_picked_flag[recipe_name] = true
    end

    datamodel.recipe_items = {}
    local recipe_category_new_flag = {}
    local show_new_tag = false
    for group, recipe_set in pairs(recipes) do
        for _, recipe_item in ipairs(recipe_set) do
            if recipe_unlocked(recipe_item.name) then
                datamodel.recipe_name = datamodel.recipe_name or recipe_item.name
                local new_recipe_flag = (not storage.recipe_picked_flag[recipe_item.name]) and true or false

                if group == cur_recipe_category_cfg.group or cur_recipe_category_cfg.group == "全部" then
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

                    datamodel.recipe_index = #datamodel.recipe_items
                end

                if new_recipe_flag then
                    recipe_category_new_flag[group] = true
                    show_new_tag = true
                end
            end
        end
    end

    if show_new_tag then
        recipe_category_new_flag["全部"] = true
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
    _update_recipe_items(datamodel, datamodel.recipe_name)
    datamodel.recipe_name = datamodel.recipe_name or ""
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
        storage.recipe_picked_flag = storage.recipe_picked_flag or {}
        storage.recipe_picked_flag[recipe_name] = true
        _update_recipe_items(datamodel, recipe_name)
    end

    for _, _, _, object_id, recipe_name in set_recipe_mb:unpack() do
        local object = assert(objects:get(object_id, {"CONSTRUCTED"}))
        local typeobject = iprototype.queryByName(object.prototype_name)
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        assert(e.assembling)

        if iworld.set_recipe(gameplay_core.get_world(), e, recipe_name, typeobject.recipe_init_limit) then
            -- TODO viewport
            local recipe_typeobject = iprototype.queryByName(recipe_name)
            assert(recipe_typeobject, ("can not found recipe `%s`"):format(recipe_name))
            object.fluid_name = irecipe.get_init_fluids(recipe_typeobject) or {} -- recipe may not have fluid

            _update_neighbor_fluidbox(object)
            gameplay_core.build()

            iui.call_datamodel_method("building_arc_menu.rml", "update", object_id)
            object.recipe = recipe_name
            itask.update_progress("set_recipe", recipe_name)
        end
    end

    for _ in clear_recipe_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))

        iworld.set_recipe(gameplay_core.get_world(), e, nil)
        object.recipe = ""
        object.fluid_name = {}

        iui.call_datamodel_method("building_arc_menu.rml", "update", object_id)

        _update_neighbor_fluidbox(object)
        gameplay_core.build()
    end
end

return M