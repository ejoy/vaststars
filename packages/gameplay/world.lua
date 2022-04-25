require "register.types"

local status = require "status"
local prototype = require "prototype"
local vaststars = require "vaststars.world.core"
local container = require "vaststars.container.core"
local fluidflow = require "vaststars.fluidflow.core"
local road = require "vaststars.road.core"
local luaecs = import_package "vaststars.ecs"

local function pipeline(world, cworld, name)
    local p = status.pipelines[name]
    if not p then
        return
    end
    local systems = status.systems
    local csystems = status.csystems
    local funcs = {}
    for _, stage in ipairs(p) do
        for _, s in pairs(systems) do
            if s[stage] then
                funcs[#funcs+1] = function(...)
                    return s[stage](world, ...)
                end
            end
        end
        for _, s in pairs(csystems) do
            if s[stage] then
                funcs[#funcs+1] = function(...)
                    return s[stage](cworld, ...)
                end
            end
        end
    end
    local n = #funcs
    return function (...)
        for i = 1, n do
            funcs[i](...)
        end
    end
end

local function deepcopy(t)
    local r = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            r[k] = deepcopy(v)
        else
            r[k] = v
        end
    end
    return r
end

return function ()
    local world = {}
    local needBuild = false
    local ecs = luaecs.world()
    local timer = dofile(package.searchpath("timer", package.path))
    local components = {}
    for _, c in ipairs(status.components) do
        assert(c.type == nil)
        ecs:register(c)
        components[#components+1] = c.name
    end

    ecs:register {
        name = "fluidbox_changed"
    }

    local context = ecs:context(components)
    local ptable = require "vaststars.prototype.core"
    local cworld = vaststars.create_world(context, ptable)
    world.ecs = ecs
    world._cworld = cworld
    world._context = context

    function world:create_entity(type)
        return function (init)
            local typeobject = assert(prototype.query("entity", type), "unknown entity: " .. type)
            local types = typeobject.type
            local obj = {}
            for i = 1, #types do
                local ctor = status.ctor[types[i]]
                if ctor then
                    for k, v in pairs(ctor(world, init, typeobject)) do
                        if obj[k] == nil then
                            obj[k] = v
                        end
                    end
                end
            end
            ecs:new(obj)
            needBuild = true
        end
    end

    function world:remove_entity(v)
        ecs:remove(v)
        needBuild = true
    end

    local pipeline_update = pipeline(world, cworld, "update")
    local pipeline_build = pipeline(world, cworld, "build")
    local pipeline_backup = pipeline(world, cworld, "backup")
    local pipeline_restore = pipeline(world, cworld, "restore")

    function world:update()
        assert(not needBuild)
        pipeline_update()
        timer.update(1)
        ecs:update()
    end
    function world:build()
        needBuild = false
        ecs:update()
        pipeline_build()
        ecs:update()
    end
    function world:backup(rootdir)
        local fs = require "bee.filesystem"
        fs.create_directories(rootdir)
        pipeline_backup(rootdir)
    end
    function world:restore(rootdir)
        pipeline_restore(rootdir)
    end

    function world:container_create(...)
        return container.create(cworld, ...)
    end
    function world:container_pickup(...)
        return container.pickup(cworld, ...)
    end
    function world:container_place(...)
        return container.place(cworld, ...)
    end
    function world:container_get(...)
        return container.get(cworld, ...)
    end
    function world:fluidflow_reset(...)
        return fluidflow.reset(cworld, ...)
    end
    function world:fluidflow_build(...)
        return fluidflow.build(cworld, ...)
    end
    function world:fluidflow_teardown(...)
        return fluidflow.teardown(cworld, ...)
    end
    function world:fluidflow_connect(...)
        return fluidflow.connect(cworld, ...)
    end
    function world:fluidflow_query(...)
        return fluidflow.query(cworld, ...)
    end
    function world:fluidflow_set(...)
        return fluidflow.set(cworld, ...)
    end
    function world:fluidflow_dump(...)
        return fluidflow.dump(cworld, ...)
    end
    function world:road_path(begining, ending)
        return road.path(context, begining, ending)
    end

    function world:wait(...)
        return timer.wait(...)
    end
    function world:loop(...)
        return timer.loop(...)
    end

    return world
end
