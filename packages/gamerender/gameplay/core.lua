local gameplay = import_package "vaststars.gameplay"
local world = gameplay.createWorld()
local gameplay_system_update = require "gameplay.system.init"
local assembling = gameplay.interface "assembling"
local STATUS_IDLE <const> = 0
local recipe_api = require "gameplay.utility.recipe"
local prototype_api = require "gameplay.prototype"

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

function m.update(get_object_func)
    -- 发电机发电逻辑
    for v in world.ecs:select "generator capacitance:out" do
        v.capacitance.shortage = 0
    end

    if m.world_update then
        world:update()
        gameplay_system_update(world, get_object_func)
    end
end

function m.container_get(...)
    return world:container_get(...)
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
    create_entity_cache[prototype](entity)
end

local init_func = {}
init_func["assembling"] = function(pt, template)
    if not pt.recipe then
        return template
    end

    -- 摆放建筑时设置配方
    -- 目前游戏过程中, 通常是先放置建筑后, 再设置配方
    local recipe_typeobject = prototype_api.queryByName("recipe", pt.recipe)
    template.fluids = recipe_api.get_fluids(recipe_typeobject)

    return template
end

function m.create_entity(init)
    local func
    local template = {
        x = init.x,
        y = init.y,
        dir = init.dir,
        fluid = init.fluid,
    }

    local pt = prototype_api.queryByName("entity", init.prototype_name)
    for _, entity_type in ipairs(pt.type) do
        func = init_func[entity_type]
        if func then
            template = assert(func(pt, template))
        end
    end

    print("gameplay create_entity", init.prototype_name, template.dir, template.x, template.y)
    create(world, init.prototype_name, template)
    return template.id
end

function m.fluidflow_query(...)
    return world:fluidflow_query(...)
end

function m.query_entity(pat, x, y)
    local e
    for v in world.ecs:select(pat) do
        if v.entity.x == x and v.entity.y == y then
            e = v
            break
        end
    end
    return e
end

function m.backup(rootdir)
    return world:backup(rootdir)
end

function m.restore(rootdir)
    world:restore(rootdir)
end

function m.restart()
    world = gameplay.createWorld()
end

function m.set_recipe(e, recipe_name)
    -- TODO 后续处理, 如果 process 不为 0, 那么需要将"已扣除的东西"归还给玩家
    e.assembling.process = 0
    e.assembling.status = STATUS_IDLE

    local recipe_typeobject = prototype_api.queryByName("recipe", recipe_name)
    assert(recipe_typeobject, ("can not found recipe `%s`"):format(recipe_name))

    local typeobject = prototype_api.query(e.entity.prototype)

    assembling.set_recipe(world, e, typeobject, recipe_name, recipe_api.get_fluids(recipe_typeobject))
    m.sync("assembling:out fluidboxes:out fluidbox_changed?out", e)

    print("set recipe success")
end

return m