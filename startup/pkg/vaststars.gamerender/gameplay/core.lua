local gameplay = import_package "vaststars.gameplay"

local function __create_gameplay_world()
    local world = gameplay.createWorld()
    return world
end

local world = __create_gameplay_world()
local irecipe = require "gameplay.interface.recipe"
local iprototype = require "gameplay.interface.prototype"
local MULTIPLE <const> = require "debugger".multiple

local m = {}
m.world_update = false
m.multiple = MULTIPLE or 1

function m.select(...)
    return world.ecs:select(...)
end

function m.extend(...)
    return world.ecs:extend(...)
end

function m.update()
    if m.world_update then
        for _ = 1, m.multiple do
            world:update()
        end
    end
end

function m.set_multiple(n)
    m.multiple = n
end

function m.remove_entity(eid)
    print("remove_entity", eid)
    world.ecs:remove(eid)
end

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

    template.fluids = template.fluid -- TODO: remove this
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

init_func["hub"] = function (pt, template)
    template.item = template.item
    return template
end

local post_funcs = {}
post_funcs["hub"] = function (pt, template)
    -- TODO: deleting a hub requires the deletion of all drone entities that are linked to it
    for _ = 1, pt.drone_count do
         create(world, pt.drone_entity, template)
    end
end

function m.create_entity(init)
    -- assert(not(init.x == 0 and init.y == 0))
    local func
    local template = {
        x = init.x,
        y = init.y,
        dir = init.dir,
        fluid = init.fluid_name,
        items = init.items,
        item = init.item,
        recipe = init.recipe, -- for debugging
    }

    local typeobject = iprototype.queryByName(init.prototype_name)
    for _, entity_type in ipairs(typeobject.type) do
        func = init_func[entity_type]
        if func then
            template = assert(func(typeobject, template))
        end
        func = post_funcs[entity_type]
        if func then
            func(typeobject, template)
        end
    end

    local eid = create(world, init.prototype_name, template)
    print("gameplay create_entity", init.prototype_name, template.dir, template.x, template.y, template.fluid or "[fluid]", template.recipe or "[recipe]", eid)
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

function m.get_storage()
    world.storage = world.storage or {}
    return world.storage
end

return m