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
local ichest = require "gameplay.interface.chest"
local iobject = ecs.require "object"
local coord_system = ecs.require "terrain"
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

    local function _has_connection(object)
        for _, fb in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir)) do
            local succ, dx, dy = terrain:move_coord(fb.x, fb.y, fb.dir, 1)
            if not succ then
                goto continue
            end

            local o = objects:coord(dx, dy, EDITOR_CACHE_NAMES)
            if not o then
                goto continue
            end

            local typeobject = iprototype.queryByName(o.prototype_name)
            if iprototype.has_type(typeobject.type, "assembling") then
                return true
            end
            ::continue::
        end
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
                if neighbor_fb.fluid_name == "" then
                    for _, sibling in objects:selectall("fluidflow_id", neighbor.fluidflow_id, {"CONSTRUCTED"}) do
                        sibling.fluid_name = fb.fluid_name
                        sibling.fluidflow_id = neighbor.fluidflow_id

                        local fluid_icon -- TODO: duplicate code, see also saveload.lua
                        local typeobject = iprototype.queryByName(sibling.prototype_name)
                        if iprototype.has_type(typeobject.type, "fluidbox") and sibling.fluid_name ~= "" then
                            if iprototype.is_pipe(sibling.prototype_name) or iprototype.is_pipe_to_ground(sibling.prototype_name) then
                                if ((sibling.x % 2 == 1 and sibling.y % 2 == 1) or (sibling.x % 2 == 0 and sibling.y % 2 == 0)) and not _has_connection(sibling) then
                                    fluid_icon = true
                                end
                            else
                                fluid_icon = true
                            end
                        end
                        sibling.fluid_icon = fluid_icon
                        ifluid:update_fluidbox(gameplay_core.get_entity(sibling.gameplay_eid), sibling.fluid_name)
                        igameplay.update_chimney_recipe(sibling)
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

local function __random_dir()
    local dir = math.random(1, 4)
    if dir == 1 then
        return "N"
    elseif dir == 2 then
        return "E"
    elseif dir == 3 then
        return "S"
    elseif dir == 4 then
        return "W"
    end
end

local function __find_empty_tile(x, y, w, h)
    local empty_tile = {}
    for i = x - 1, x + w do
        for j = y - 1, y + h do
            if not objects:coord(i, j) then
                empty_tile[#empty_tile + 1] = {i, j}
            end
        end
    end
    return empty_tile
end

local function __throw_construction_chest(e, x, y, w, h)
    local olditems = {}
    local old_recipe = iprototype.queryById(e.assembling.recipe)

    if old_recipe then
        local ingredients_n <const> = #old_recipe.ingredients//4 - 1
        local results_n <const> = #old_recipe.results//4 - 1
        for i = 1, results_n do
            local slot = ichest.chest_get(gameplay_core.get_world(), e.chest, i + ingredients_n)
            if slot and slot.item ~= 0 and ichest.get_amount(slot) > 0 then
                olditems[#olditems+1] = slot
            end
        end

        if #olditems > 0 then
            local empty_tile = __find_empty_tile(x, y, w, h)
            if #empty_tile < #olditems then
                log.error("not enough space to place items")
                return false
            end

            for i, slot in ipairs(olditems) do
                local v = empty_tile[i]
                local x, y = v[1], v[2]
                local item = iprototype.queryById(slot.item)
                local amount = ichest.get_amount(slot)

                assert(ichest.chest_pickup(gameplay_core.get_world(), e.chest, slot.item, amount))

                local o = iobject.new {
                    prototype_name = "建材箱", -- TODO: remove hardcode
                    dir = __random_dir(),
                    x = x,
                    y = y,
                    srt = {
                        t = coord_system:get_position_by_coord(x, y, 1, 1),
                    },
                }
                local entity = {
                    prototype_name = o.prototype_name,
                    dir = o.dir,
                    x = o.x,
                    y = o.y,
                    items = {
                        {item.name, amount},
                    },
                }
                o.gameplay_eid = igameplay.create_entity(entity)

                objects:set(o, "CONSTRUCTED")
            end

            gameplay_core.build()
        end
    end
    return true
end

---------------
local M = {}

function M:create(object_id, construction_center)
    local datamodel = {}
    _show_object_recipe(datamodel, object_id)
    _update_recipe_items(datamodel, datamodel.recipe_name)
    datamodel.recipe_name = datamodel.recipe_name or ""
    datamodel.construction_center = construction_center
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
        if not __throw_construction_chest(e, object.x, object.y, iprototype.unpackarea(typeobject.area)) then
            goto continue
        end

        if iworld.set_recipe(gameplay_core.get_world(), e, recipe_name, typeobject.recipe_init_limit) then
            -- TODO viewport
            local recipe_typeobject = iprototype.queryByName(recipe_name)
            assert(recipe_typeobject, ("can not found recipe `%s`"):format(recipe_name))
            object.fluid_name = irecipe.get_init_fluids(recipe_typeobject) or {} -- recipe may not have fluid

            _update_neighbor_fluidbox(object)
            gameplay_core.build()

            iui.update("building_arc_menu.rml", "update", object_id)
            object.recipe = recipe_name
            itask.update_progress("set_recipe", recipe_name)
        end
        ::continue::
    end

    for _ in clear_recipe_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        local typeobject = iprototype.queryByName(object.prototype_name)
        if not __throw_construction_chest(e, object.x, object.y, iprototype.unpackarea(typeobject.area)) then
            goto continue
        end

        iworld.set_recipe(gameplay_core.get_world(), e, nil)
        object.recipe = ""
        object.fluid_name = {}

        iui.update("building_arc_menu.rml", "update", object_id)

        _update_neighbor_fluidbox(object)
        gameplay_core.build()
        ::continue::
    end
end

return M