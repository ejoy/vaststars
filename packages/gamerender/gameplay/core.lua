local gameplay = import_package "vaststars.gameplay"
local world = gameplay.createWorld()
local assembling = gameplay.interface "assembling"
local irecipe = require "gameplay.utility.recipe"
local iprototype = require "gameplay.prototype"

local m = {}
m.world_update = true

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
    -- 发电机发电逻辑
    for v in world.ecs:select "generator capacitance:out" do
        v.capacitance.shortage = 0
    end

    if m.world_update then
        world:update()
    end
end

function m.container_get(...)
    return world:container_get(...)
end

function m.container_place(...)
    return world:container_place(...)
end

function m.remove_entity(v)
    return world:remove_entity(v)
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
    if not pt.recipe then
        return template
    end

    -- 摆放建筑时设置配方
    -- 目前游戏过程中, 通常是先放置建筑后, 再设置配方
    local typeobject = iprototype:queryByName("recipe", pt.recipe)
    template.fluids = irecipe:get_init_fluids(typeobject)

    return template
end

function m.create_entity(init)
    local func
    local template = {
        x = init.x,
        y = init.y,
        dir = init.dir,
        fluid = init.fluid,
        items = init.items,
    }

    local pt = iprototype:queryByName("entity", init.prototype_name)
    for _, entity_type in ipairs(pt.type) do
        func = init_func[entity_type]
        if func then
            template = assert(func(pt, template))
        end
    end

    print("gameplay create_entity", init.prototype_name, template.dir, template.x, template.y)
    return create(world, init.prototype_name, template)
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

function m.set_recipe(e, recipe_name)
    local recipe_typeobject = iprototype:queryByName("recipe", recipe_name)
    assert(recipe_typeobject, ("can not found recipe `%s`"):format(recipe_name))

    local typeobject = iprototype:query(e.entity.prototype)
    local init_fluids = irecipe:get_init_fluids(recipe_typeobject)

    if init_fluids then
        if #typeobject.fluidboxes.input ~= #init_fluids.input then
            log.error(("failed to set recipe: input %s %s"):format(#typeobject.fluidboxes.input, #init_fluids.input))
            return
        end
        if #typeobject.fluidboxes.output ~= #init_fluids.output then
            log.error(("failed to set recipe: output %s %s"):format(#typeobject.fluidboxes.output, #init_fluids.output))
            return
        end
    end

    assembling.set_recipe(world, e, typeobject, recipe_name, init_fluids)
    -- m.sync("assembling:out fluidboxes:out fluidbox_changed?out", e)

    log.info(("set recipe success `%s`"):format(recipe_name))
end

return m