local gameplay = import_package "vaststars.gameplay"
local world = gameplay.createWorld()
local irecipe = require "gameplay.interface.recipe"
local iprototype = require "gameplay.interface.prototype"
local imining = require "gameplay.interface.mining" -- TODO: remove this

local m = {}
m.world_update = true
m.multiple = 1

function m.select(...)
    return world.ecs:select(...)
end

function m.sync(...)
    return world.ecs:sync(...)
end

function m.build(...)
    return world:build()
end

function m.update()
    if m.world_update then
        for i = 1, m.multiple do
            world:update()
        end
    end
end

function m.set_multiple(n)
    m.multiple = n
end

function m.container_get(...)
    return world:container_get(...)
end

function m.container_pickup(...)
    return world:container_pickup(...)
end

function m.container_place(...)
    return world:container_place(...)
end

function m.remove_entity(eid)
    print("remove_entity", eid)
    world:remove_entity(eid)
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
    if not template.recipe then
        return template
    end

    local typeobject = iprototype.queryByName("recipe", template.recipe)
    template.fluids = irecipe.get_init_fluids(typeobject)

    return template
end

init_func["chimney"] = function (pt, template)
    if not template.recipe then
        return template
    end

    local typeobject = iprototype.queryByName("recipe", template.recipe)
    template.fluids = irecipe.get_init_fluids(typeobject)

    return template
end

function m.create_entity(init)
    local func
    local template = {
        x = init.x,
        y = init.y,
        dir = init.dir,
        fluid = init.fluid_name,
        items = init.items,
        recipe = init.recipe, -- for debugging
    }

    local typeobject = iprototype.queryByName("entity", init.prototype_name)
    for _, entity_type in ipairs(typeobject.type) do
        func = init_func[entity_type]
        if func then
            template = assert(func(typeobject, template))
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
    return world.entity.readall(eid)
end

function m.backup(rootdir)
    return world:backup(rootdir)
end

function m.restore(rootdir)
    world:restore(rootdir)
end

function m.restart()
    create_entity_cache = {}
    world = gameplay.createWorld()
end

function m.manual_chest()
    local chest = {}
    local ecs = world.ecs
    for v in ecs:select "manual chest:in" do
        local i = 1
        while true do
            local c, n = world:container_get(v.chest.container, i)
            if c then
                chest[gameplay.prototype.queryById(c).name] = n
            else
                break
            end
            i = i + 1
        end
        break
    end
    return chest
end

return m