require "register.types"

local status = require "status"
local prototype = require "prototype"
local vaststars = require "vaststars.world.core"
local chest = require "vaststars.chest.core"
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
    local ecs = luaecs.world()
    local timer = dofile(package.searchpath("timer", package.path))
    local components = {}
    for _, c in ipairs(status.components) do
        assert(c.type == nil)
        ecs:register(c)
        components[#components+1] = c.name
    end

    local context = ecs:context(components)
    local cworld = vaststars.create_world(context)
    world.ecs = ecs
    world._cworld = cworld
    world._context = context

    --TOOD: 如果可以提前得知需要读档，这个操作是可以省略的
    prototype.restore(cworld, {})

    function world:create_entity(type)
        return function (init)
            local typeobject = assert(prototype.queryByName(type), "unknown entity: " .. type)
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
        local pt = prototype.queryByName(tech)
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
                local pt = prototype.queryByName(v)
                assert(pt, "unknown tech: " .. v)
                q[i] = pt.id
            end
            return cworld:research_queue(q)
        end
    end

    function world:research_progress(tech, progress)
        local pt = prototype.queryByName(tech)
        assert(pt, "unknown tech: " .. tech)
        if progress then
            return cworld:research_progress(pt.id, progress)
        else
            return cworld:research_progress(pt.id)
        end
    end

    function world:fluidflow_query(fluid, id)
        return cworld:fluidflow_query(fluid, id)
    end

    local CHEST_TYPE <const> = {
        [0] = 0,
        [1] = 1,
        [2] = 2,
        [3] = 3,
        red = 0,
        blue = 1,
        green = 2,
        none = 3,
    }
    function world:chest_slot(t)
        assert(t.type)
        assert(t.item)
        local id = t.item
        if type(id) == "string" then
            id = prototype.queryByName(id).id
        end
        return string.pack("<I1I1I2I2I2I2I2",
            CHEST_TYPE[t.type],
            0,
            id,
            t.amount or 0,
            t.limit or 2,
            t.lock_item or 0,
            t.lock_space or 0
        )
    end

    function world:container_create(info)
        return chest.create(cworld, info)
    end
    function world:container_destroy(c)
        return chest.destroy(cworld, c.chest)
    end
    function world:container_get(c, i)
        return chest.get(cworld, c.chest, i)
    end
    function world:container_set(c, i, t)
        return chest.set(cworld, c.chest, i, t)
    end
    function world:container_pickup(c, item, amount)
        return chest.pickup(cworld, c.chest, item, amount)
    end
    function world:container_place(c, item, amount)
        chest.place(cworld, c.chest, item, amount)
    end

    function world:wait(...)
        return timer.wait(...)
    end
    function world:loop(...)
        return timer.loop(...)
    end
    function world:now(...)
        return timer.now(...)
    end

    for name, f in pairs(roadnet) do
        world["roadnet_"..name] = function (_, ...)
            return f(cworld, ...)
        end
    end

    return world
end
