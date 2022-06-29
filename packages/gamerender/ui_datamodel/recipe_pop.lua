local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local set_recipe_mb = mailbox:sub {"set_recipe"}
local recipe_menu_cfg = import_package "vaststars.prototype"("recipe_category")
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
local iobject = ecs.require "object"

local recipe_menu = {} ; do
    local recipes = {}
    for _, v in pairs(iprototype.all_prototype_name("recipe")) do
        recipes[v.category] = recipes[v.category] or {}
        recipes[v.category][#recipes[v.category] + 1] = {
            name = v.name,
            order = v.order,
            icon = v.icon,
            time = v.time,
            ingredients = irecipe.get_elements(v.ingredients),
            results = irecipe.get_elements(v.results),
            group = v.group,
        }
    end

    for _, menu in ipairs(recipe_menu_cfg) do
        local m = {}
        m.group = menu.group
        m.icon = menu.icon
        m.item = {}

        for _, category in ipairs(menu.category) do
            assert(recipes[category], ("can not found category `%s`, define in package.prototype.recipe"):format(category))
            for _, v in ipairs(recipes[category]) do
                if v.group == menu.group then
                    m.item[#m.item + 1] = v
                end
            end
        end
        table.sort(m.item, function(a, b) return a.order < b.order end)

        recipe_menu[#recipe_menu+1] = m
    end
end

local function get_recipe_index(recipe_menu, recipe_name)
    for index, v1 in ipairs(recipe_menu) do
        for recipe_index, v2 in ipairs(v1.item) do
            if v2.name == recipe_name then
                return index, recipe_index
            end
        end
    end

    log.error(("can not found recipe `%s`"):format(recipe_name))
    return 1, 1
end

local function is_connection(x1, y1, dir1, x2, y2, dir2)
    local dx1, dy1 = ieditor:get_dir_coord(x1, y1, dir1)
    local dx2, dy2 = ieditor:get_dir_coord(x2, y2, dir2)
    return (dx1 == x2 and dy1 == y2) and (dx2 == x1 and dy2 == y1)
end

local function shift_pipe(prototype_name, x, y, dir, fluid_name)
    for _, v in ipairs(ifluid:get_fluidbox(prototype_name, x, y, dir, fluid_name)) do
        local dx, dy = ieditor:get_dir_coord(v.x, v.y, v.dir)
        local object = objects:coord(dx, dy)
        if object then
            local typeobject = iprototype.queryByName("entity", object.prototype_name)
            if typeobject.pipe then
                for _, v1 in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) do
                    if is_connection(v.x, v.y, v.dir, v1.x, v1.y, v1.dir) then
                        if object.fluidflow_network_id ~= 0 then
                            for _, object in objects:selectall("fluidflow_network_id", object.fluidflow_network_id, {"CONSTRUCTED"}) do
                                local o = iobject.clone(object)
                                o.fluidflow_network_id = 0
                                o.fluid_name = v.fluid_name
                                objects:set(o, "CONSTRUCTED")

                                ifluid:update_fluidbox(gameplay_core.get_entity(o.gameplay_eid), o.fluid_name)
                            end
                        else
                            if object.fluid_name ~= v.fluid_name then
                                local prototype_name, dir = ieditor:refresh_pipe(object.prototype_name, object.dir, v1.dir, 0)
                                if prototype_name ~= object.prototype_name or dir ~= object.dir then
                                    object = iobject.clone(object)
                                    object.prototype_name = prototype_name
                                    object.dir = dir
                                    objects:set(object)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    gameplay_core.build()
end

---------------
local M = {}

function M:create(object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end

    local recipe_name = ""
    if e.assembling.recipe ~= 0 then
        local recipe_typeobject = iprototype.queryById(e.assembling.recipe)
        recipe_name = recipe_typeobject.name
    end

    local catalog_index = 1
    local recipe_index = 0
    local items

    if e.assembling.recipe ~= 0 then
        catalog_index, recipe_index = get_recipe_index(recipe_menu, recipe_name)
    end

    if recipe_menu[catalog_index] then
        items = recipe_menu[catalog_index].item
    end

    return {
        object_id = object_id,
        recipe_index = recipe_index,
        recipe_name = recipe_name,
        recipe_menu = recipe_menu,
        catalog_index = catalog_index,
        items = items or {}
    }
end

function M:update(datamodel, param, object_id)
    if param[1] ~= object_id then
        return
    end

    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end

    if e.assembling.recipe ~= 0 then
        local recipe_typeobject = iprototype.queryById(e.assembling.recipe)
        datamodel.recipe_name = recipe_typeobject.name
        datamodel.catalog_index, datamodel.recipe_index = get_recipe_index(recipe_menu, datamodel.recipe_name)
    end

    datamodel.items = datamodel.recipe_menu[datamodel.catalog_index].item or {}
end

function M:stage_ui_update(datamodel, object_id)
    for _, _, _, object_id, recipe_name in set_recipe_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        if e.assembling then
            -- TODO
            -- 修改配方前回收组装机里的物品
            local item_counts = {}
            local e = gameplay_core.get_entity(object.gameplay_eid)
            if e.assembling then
                for prototype_name, count in pairs(iassembling:item_counts(gameplay_core.get_world(), e)) do
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
                object.fluid_name = irecipe.get_init_fluids(recipe_typeobject) or {} -- 配方中没有流体的情况

                shift_pipe(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)
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

        shift_pipe(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)
        gameplay_core.build()
    end
end

return M