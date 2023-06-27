local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local igameplay = ecs.interface "igameplay"
local iprototype = require "gameplay.interface.prototype"
local ichimney = require "gameplay.interface.chimney"
local terrain = ecs.require "terrain"
local objects = require "objects"
local EDITOR_CACHE_NAMES = {"CONFIRM", "CONSTRUCTED"}
local ifluid = require "gameplay.interface.fluid"

local funcs = {}
funcs["chimney"] = function(object, typeobject)
    local succ, dx, dy, fluid_name
    for _, fb in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir)) do
        succ, dx, dy = terrain:move_coord(fb.x, fb.y, fb.dir, 1)
        if not succ then
            goto continue
        end

        local another = objects:coord(dx, dy, EDITOR_CACHE_NAMES)
        if not another then
            goto continue
        end

        for _, afb in ipairs(ifluid:get_fluidbox(another.prototype_name, another.x, another.y, another.dir, another.fluid_name)) do
            if afb.x == dx and afb.y == dy then
                fluid_name = afb.fluid_name
            end
        end

        ::continue::
    end

    if not fluid_name or fluid_name == "" then
        return object
    end

    local recipe = ichimney.get_recipe(typeobject.craft_category, fluid_name)
    if not recipe then
        return object
    end

    object.recipe = recipe
    return object
end

funcs["fluidbox"] = function (object, typeobject)
    if iprototype.has_type(typeobject.type, "chimney") then
        return object
    end

    if object.fluid_name == "" then
        return object
    end

    local succ, dx, dy, found, found_typeobject
    for _, fb in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir)) do
        succ, dx, dy = terrain:move_coord(fb.x, fb.y, fb.dir, 1)
        if not succ then
            goto continue
        end

        local chimney = objects:coord(dx, dy, EDITOR_CACHE_NAMES)
        if not chimney then
            goto continue
        end

        local _typeobject = iprototype.queryByName(chimney.prototype_name)
        if not iprototype.has_type(_typeobject.type, "chimney") then
            goto continue
        end

        for _, afb in ipairs(ifluid:get_fluidbox(chimney.prototype_name, chimney.x, chimney.y, chimney.dir, chimney.fluid_name)) do
            if afb.x == dx and afb.y == dy then
                found, found_typeobject = chimney, _typeobject
            end
        end

        ::continue::
    end

    if not found then
        return object
    end

    local fluid_name = object.fluid_name
    found.fluid_name = fluid_name

    if not found.gameplay_eid then -- not yet created in gameplay
        local recipe = ichimney.get_recipe(found_typeobject.craft_category, fluid_name)
        if not recipe then
            return object
        end
        found.recipe = recipe
    else
        local e = gameplay_core.get_entity(found.gameplay_eid)
        local recipe = ichimney.get_recipe(found_typeobject.craft_category, fluid_name)
        if not recipe then
            return object
        end
        ifluid:update_fluidbox(gameplay_core.get_world(), e, fluid_name)
    end
    return object
end

funcs["fluidboxes"] = funcs["fluidbox"]

function igameplay.create_entity(init)
    local typeobject = iprototype.queryByName(init.prototype_name)
    for _, v in ipairs(typeobject.type) do
        if funcs[v] then
            init = funcs[v](init, typeobject)
        end
    end

    local eid = gameplay_core.create_entity(init)
    world:pub {"gameplay", "create_entity", eid, typeobject}
    return eid
end

function igameplay.remove_entity(eid)
    world:pub {"gameplay", "remove_entity", eid}

    local e = gameplay_core.get_entity(eid)
    if e.chest then
        if e.chest.index ~= nil then
            gameplay_core.get_world():container_rollback(e.chest)
        end
    end
    return gameplay_core.remove_entity(eid)
end

function igameplay.update_chimney_recipe(object) -- TODO: better way to do this?
    local typeobject = iprototype.queryByName(object.prototype_name)
    for _, v in ipairs(typeobject.type) do
        if funcs[v] then
            object = funcs[v](object, typeobject)
        end
    end
end
