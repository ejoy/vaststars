local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local global = require "global"
local cache_names = global.cache_names
local objects = global.objects
local iprototype = require "gameplay.interface.prototype"
local iassembling = require "gameplay.interface.assembling"
local ientity = require "gameplay.interface.entity"
local vsobject_manager = ecs.require "vsobject_manager"
local terrain = ecs.require "terrain"
local iui = ecs.import.interface "vaststars.gamerender|iui"

local rotate_mb = mailbox:sub {"rotate"}
local recipe_mb = mailbox:sub {"recipe"}
local detail_mb = mailbox:sub {"detail"}
local pickup_material_mb = mailbox:sub {"pickup_material"}
local place_material_mb = mailbox:sub {"place_material"}
---------------
local M = {}

function M:create(object_id, left, top)
    local object = assert(objects:get(cache_names, object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end
    local typeobject = iprototype:queryByName("entity", object.prototype_name)

    -- 组装机才显示设置配方菜单
    local show_material_button = false
    local show_set_recipe = false
    local recipe_name = ""
    if iprototype:has_type(typeobject.type, "assembling") then
        assert(e.assembling)

        -- typeobject.recipe == nil means need to set recipe
        show_set_recipe = (typeobject.recipe == nil)
        if e.assembling.recipe ~= 0 then
            local typeobject = iprototype:query(e.assembling.recipe)
            recipe_name = typeobject.name
            show_material_button = true
        end
    end

    return {
        show_set_recipe = show_set_recipe,
        show_material_button = show_material_button,
        recipe_name = recipe_name,
        object_id = object_id,
        left = ("%0.2fvmin"):format(math.max(left - 41.5, 0)),
        top = ("%0.2fvmin"):format(math.max(top - 30, 0)),
    }
end

function M:update(datamodel, object_id, recipe_name)
    if datamodel.object_id ~= object_id then
        return
    end
    datamodel.recipe_name = recipe_name
    return true
end

function M:stage_ui_update(datamodel)
    --
    for _, _, _, object_id in rotate_mb:unpack() do
        local object = assert(objects:get(cache_names, object_id))
        local vsobject = assert(vsobject_manager:get(object_id))
        local dir = iprototype:rotate_dir_times(object.dir, -1)

        local typeobject = iprototype:queryByName("entity", object.prototype_name)
        local _, position = terrain.adjust_position_by_coord(object.x, object.y, vsobject:get_position(), iprototype:rotate_area(typeobject.area, dir))
        if not position then
            return
        end

        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        if e then
            ientity:set_direction(gameplay_core.get_world(), e, dir)

            object.dir = dir
            vsobject:set_position(position)
            vsobject:set_dir(object.dir)

            gameplay_core.build()
        else
            log.error(("can not found entity (%s, %s)"):format(object.x, object.y))
        end
    end

    for _, _, _, object_id in recipe_mb:unpack() do
        iui.open("recipe_pop.rml", object_id)
    end

    for _, _, _, object_id in detail_mb:unpack() do
        local object = assert(objects:get(cache_names, object_id))
        local typeobject = iprototype:queryByName("entity", object.prototype_name)
        if iprototype:has_type(typeobject.type, "assembling") then
            iui.open("assemble_2.rml", object_id)
        elseif iprototype:has_type(typeobject.type, "chest") then
            iui.open("cmdcenter.rml", object_id)
        elseif iprototype:has_type(typeobject.type, "laboratory") then
            iui.open("lab.rml", object_id)
        else
            log.error("no detail")
        end
    end

    for _, _, _, object_id in pickup_material_mb:unpack() do
        local object = assert(objects:get(cache_names, object_id))
        local e = gameplay_core.get_entity(object.gameplay_eid)
        iassembling:pickup_material(gameplay_core.get_world(), e)
    end

    for _, _, _, object_id in place_material_mb:unpack() do
        local object = assert(objects:get(cache_names, object_id))
        local e = gameplay_core.get_entity(object.gameplay_eid)
        iassembling:place_material(gameplay_core.get_world(), e)
    end
end

return M