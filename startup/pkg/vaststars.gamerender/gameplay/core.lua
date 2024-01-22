local gameplay = import_package "vaststars.gameplay"
local function __create_gameplay_world()
    local world = gameplay.createWorld()
    return world
end

local world = __create_gameplay_world()
local irecipe = require "gameplay.interface.recipe"
local iprototype = require "gameplay.interface.prototype"

local m = {}
m.world_update = false
m.system_changed_flags = 0

function m.is_researched(...)
    return world:is_researched(...)
end

local create_entity_cache = {}
local function create(world, prototype, entity)
    if not create_entity_cache[prototype] then
        create_entity_cache[prototype] = world:create_entity(prototype)
        if not create_entity_cache[prototype] then
            log.error(("failed to create entity `%s`"):format(prototype))
            return
        end
    end
    return create_entity_cache[prototype](entity)
end

local init_func = {}
init_func["assembling"] = function(pt, template)
    local recipe = pt.recipe or template.recipe
    if pt.recipe and template.recipe then
        assert(pt.recipe == template.recipe) -- when both are set, they must be the same
    end

    if not recipe then
        return template
    end

    local recipe_typeobject = iprototype.queryByName(recipe)
    if recipe_typeobject then
        template.fluids = irecipe.get_init_fluids(recipe_typeobject) or "" -- maybe no fluid in recipe
    end

    return template
end

init_func["chimney"] = function (pt, template)
    if not template.recipe then
        return template
    end

    local typeobject = iprototype.queryByName(template.recipe)
    template.fluids = irecipe.get_init_fluids(typeobject)

    return template
end

init_func["road"] = function (pt, template)
    return template
end

init_func["base"] = function (pt, template)
    local items = {}
    for _ = 1, pt.maxslot do
        items[#items+1] = {"", 0}
    end
    template.items = items
    return template
end

function m.create_entity(init)
    -- assert(not(init.x == 0 and init.y == 0))
    local func
    local template = {
        x = init.x,
        y = init.y,
        dir = init.dir,
        items = init.items,
        item = init.item,
        recipe = init.recipe, -- for debugging
        amount = init.amount,
        debris = init.debris,
    }

    local typeobject = iprototype.queryByName(init.prototype_name)
    for _, entity_type in ipairs(typeobject.type) do
        func = init_func[entity_type]
        if func then
            template = assert(func(typeobject, template))
        end
    end

    local eid = create(world, init.prototype_name, template)
    -- print("gameplay create_entity", init.prototype_name, template.dir, template.x, template.y, template.fluid or "[fluid]", template.recipe or "[recipe]", eid)
    return eid
end

function m.fluidflow_query(...)
    return world:fluidflow_query(...)
end

function m.get_entity(eid)
    return world.entity[eid]
end

function m.get_world()
    return world
end

function m.debug_entity(eid)
    return world.ecs:readall(eid)
end

function m.backup(rootdir)
    return world:backup(rootdir)
end

function m.restore(rootdir)
    world:restore(rootdir)
end

function m.restart()
    create_entity_cache = {}
    world = __create_gameplay_world()
end

function m.get_storage(key, defvalue)
    world.storage = world.storage or {}
    if not key then
        return world.storage
    else
        if world.storage[key] == nil then
            return defvalue
        else
            return world.storage[key]
        end
    end
end

function m.set_changed(flag)
    m.system_changed_flags = m.system_changed_flags | flag
end

return m