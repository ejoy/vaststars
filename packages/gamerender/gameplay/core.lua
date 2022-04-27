local gameplay = import_package "vaststars.gameplay"
local world = gameplay.createWorld()
local gameplay_system_update = require "gameplay.system.init"
local assembling = gameplay.interface "assembling"
local STATUS_IDLE <const> = 0

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

local function isFluidId(id)
    return id & 0x0C00 == 0x0C00
end

local function get_fluid_list(fluidboxes, classify, s)
    local lst = fluidboxes[classify]
    assert(lst)

    local r = {}
    for idx = 1, #s//4 do
        local id = string.unpack("<I2I2", s, 4*idx-3)
        if isFluidId(id) then
            local pt = gameplay.query(id)
            r[#r + 1] = pt.name
        end
    end
    return r
end

local init_func = {}
init_func["assembling"] = function(pt, template)
    if not pt.recipe then
        log.error(("assembling can not found recipe `%s`"):format(pt.name))
        return template --TODO 临时处理, 防止报错, 后续加上配方设置后, 去除返回
    end
    local r = gameplay.queryByName("recipe", pt.recipe)

    local output = get_fluid_list(pt.fluidboxes, "output", r.results)
    if #output > 0 then
        template.fluids = {
            output = output
        }
    end

    return template
end

init_func["chest"] = function(pt, template)
    template.items = {
        {"铁矿石", 10},
    }
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

    local pt = gameplay.queryByName("entity", init.prototype_name)
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

function m.get_entity(pat, x, y)
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

function m.set_recipe(e, typeobject, recipe_name)
    -- TODO 后续处理, 如果 process 不为 0, 那么需要将"已扣除的东西"归还给玩家
    e.assembling.process = 0
    e.assembling.status = STATUS_IDLE
    assembling.set_recipe(world, e, typeobject, recipe_name)
end

return m