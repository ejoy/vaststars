local ecs = ...

local global = require "global"
local cache_names = global.cache_names
local objects = global.objects
local vsobject_manager = ecs.require "vsobject_manager"
local terrain = ecs.require "terrain"
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iworld = require "gameplay.interface.world"

local M = {}

function M:rotate_object(id)
    local object = assert(objects:get(cache_names, id))
    local vsobject = assert(vsobject_manager:get(id))
    local dir = iprototype:rotate_dir_times(object.dir, -1)

    local typeobject = iprototype:queryByName("entity", object.prototype_name)
    local _, position = terrain.adjust_position_by_coord(object.x, object.y, vsobject:get_position(), iprototype:rotate_area(typeobject.area, dir))
    if not position then
        return
    end

    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if e then
        local entity = e.entity
        entity.direction = iprototype:dir_tonumber(dir)
        e.entity = entity
    else
        log.error(("can not found entity (%s, %s)"):format(object.x, object.y))
    end

    object.dir = dir
    vsobject:set_position(position)
    vsobject:set_dir(object.dir)

    gameplay_core.build()
end

function M:set_recipe(id, recipe_name)
    local object = assert(objects:get(cache_names, id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if e.assembling then
        iworld:set_recipe(gameplay_core.get_world(), e, recipe_name)
        gameplay_core.build()

        iui.update("assemble_2.rml", "update", id, recipe_name)
        iui.update("build_function_pop.rml", "update", id, recipe_name)
    else
        log.error(("can not found assembling `%s`(%s, %s)"):format(object.name, object.x, object.y))
    end
end
return M