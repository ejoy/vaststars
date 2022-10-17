require "register.types"

local status = require "status"
local prototype = require "prototype"
local vaststars = require "vaststars.world.core"
local container = require "vaststars.container.core"
local roadnet = require "vaststars.roadnet.core"
local luaecs = import_package "ant.luaecs"

local perf -- = {}

local function pipeline(world, cworld, name)
    local p = status.pipelines[name]
    if not p then
        return function ()
        end
    end
    local systems = status.systems
    local csystems = status.csystems
    local funcs = {}
    local symbols = {}
    for _, stage in ipairs(p) do
        for _, v in ipairs(systems) do
            local sysname, s = v[1], v[2]
            if s[stage] then
                funcs[#funcs+1] = s[stage]
                symbols[#symbols+1] = "lua."..sysname.."."..stage
            end
        end
        for _, v in ipairs(csystems) do
            local sysname, s = v[1], v[2]
            if s[stage] then
                funcs[#funcs+1] = s[stage]
                symbols[#symbols+1] = "c."..sysname.."."..stage
            end
        end
    end
    if perf then
        local f, time = cworld.system_perf_solve(cworld, world, funcs)
        perf[name] = {
            symbol = symbols,
            time = time,
        }
        return f
    end
    return cworld.system_solve(cworld, world, funcs)
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

    ecs:register {
        name = "endpoint_changed"
    }

    local context = ecs:context(components)
    local ptable = require "vaststars.prototype.core"
    local cworld = vaststars.create_world(context, ptable)
    world.ecs = ecs
    world.roadnet = roadnet.create_world()
    world._cworld = cworld
    world._context = context

    function world:create_entity(type)
        return function (init)
            local typeobject = assert(prototype.queryByName("entity", type), "unknown entity: " .. type)
            local types = typeobject.type
            local obj = {}
            for i = 1, #types do
                local funcs = status.typefuncs[types[i]]
                if funcs and funcs.ctor then
                    for k, v in pairs(funcs.ctor(world, init, typeobject)) do
                        if obj[k] == nil then
                            obj[k] = v
                        end
                    end
                end
            end
            return ecs:new(obj)
        end
    end

    world.entity = ecs:visitor_create()

    local pipeline_update = pipeline(world, cworld, "update")
    local pipeline_clean = pipeline(world, cworld, "clean")
    local pipeline_build = pipeline(world, cworld, "build")
    local pipeline_backup = pipeline(world, cworld, "backup")
    local pipeline_restore = pipeline(world, cworld, "restore")

    local perf_frame = 0
    local function perf_print(per)
        local t = {}
        for _, v in pairs(perf) do
            local time = v.time
            for i, name in ipairs(v.symbol) do
                t[#t+1] = {name, time[i]}
            end
        end
        table.sort(t, function (a, b)
            return a[2] > b[2]
        end)
        local s = {
            "",
            "cpu stat"
        }
        for _, v in ipairs(t) do
            local m = v[2] / per
            if m >= 0.01 then
                s[#s+1] = ("\t%s - %.02fms"):format(v[1], m)
            end
        end
        print(table.concat(s, "\n"))
    end

    local function perf_reset()
        for _, v in pairs(perf) do
            local time = v.time
            for i = 1, #time do
                time[i] = 0
            end
        end
    end

    function world:perf_print()
        if not perf then
            return
        end
        local skip <const> = 0
        local delta <const> = 100
        perf_frame = perf_frame + 1
        if perf_frame <= skip then
            perf_reset()
            return
        elseif perf_frame % delta ~= 0 then
            return
        end
        perf_print(perf_frame)
    end

    function world:update()
        self:perf_print()
        pipeline_update()
        timer.update(1)
        ecs:visitor_update()
        ecs:update()
    end
    function world:build()
        pipeline_clean()
        ecs:update()
        pipeline_build()
        ecs:update()
    end
    function world:backup(rootdir)
        local fs = require "bee.filesystem"
        fs.create_directories(rootdir)
        world.storage_path = rootdir
        pipeline_backup()
    end
    function world:restore(rootdir)
        world.storage_path = rootdir
        cworld:reset()
        pipeline_restore()
    end

    function world:is_researched(tech)
        local pt = prototype.queryByName("tech", tech)
        assert(pt, "unknown tech: " .. tech)
        return cworld:is_researched(pt.id)
    end

    function world:research_queue(queue)
        if queue == nil then
            local q = cworld:research_queue()
            for i, v in ipairs(q) do
                local pt = prototype.queryById(v)
                assert(pt, "unknown tech: " .. v)
                q[i] = pt.name
            end
            return q
        else
            local q = {}
            for i, v in ipairs(queue) do
                local pt = prototype.queryByName("tech", v)
                assert(pt, "unknown tech: " .. v)
                q[i] = pt.id
            end
            return cworld:research_queue(q)
        end
    end

    function world:research_progress(tech, progress)
        local pt = prototype.queryByName("tech", tech)
        assert(pt, "unknown tech: " .. tech)
        if progress then
            return cworld:research_progress(pt.id, progress)
        else
            return cworld:research_progress(pt.id)
        end
    end

    function world:manual(lst)
        if lst == nil then
            lst = {}
            for _, v in ipairs(cworld:manual()) do
                local type, id = v[1], v[2]
                if type == "separator" then
                    lst[#lst+1] = {type, id}
                else
                    local pt = prototype.queryById(id)
                    assert(pt, "unknown ID: " .. id)
                    lst[#lst+1] = {type, pt.name}
                end
            end
            return lst
        end
        local todos = {}
        for i, v in ipairs(lst) do
            local type, id = v[1], v[2]
            if type == "crafting" then
                local pt = prototype.queryByName("recipe", id)
                assert(pt, "unknown recipe: " .. id)
                todos[i] = { type, pt.id }
            elseif type == "finish" then
                local pt = prototype.queryByName("item", id)
                assert(pt, "unknown item: " .. id)
                todos[i] = { type, pt.id }
            elseif type == "separator" then
                todos[i] = { type, id }
            else
                error("unknown type: "..type)
            end
        end
        return cworld:manual(todos)
    end

    function world:manual_container()
        local c = {}
        local cc = cworld:manual_chest()
        for k, v in pairs(cc) do
            local pt = prototype.queryById(k)
            assert(pt, "unknown ID: " .. k)
            c[pt.name] = v
        end
        return c
    end

    function world:fluidflow_query(fluid, id)
        return cworld:fluidflow_query(fluid, id)
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

    function world:wait(...)
        return timer.wait(...)
    end
    function world:loop(...)
        return timer.loop(...)
    end

    return world
end
