require "register.types"

local luaecs = import_package "ant.luaecs"
local status = require "status"
local prototype = require "prototype"
local cWorld = require "vaststars.world.core"
local cFluidflow = require "vaststars.fluidflow.core"
local iChest = require "interface.chest"
local iBuilding = require "interface.building"

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
    return cworld.system_solve(cworld, world, funcs)
end

return function ()
    local world = {
        _frame = 0,
    }
    local ecs = luaecs.world()
    for i, c in ipairs(require "register.component") do
        assert(c.type == nil)
        local id = ecs:register(c)
        assert(id == i)
    end

    ecs:new {
        global_state = {
            pollution = 0,
            consumer_multiplier = 100,
        }
    }
    local context = ecs:context()
    local cworld = cWorld.create_world(context)
    world.ecs = ecs
    world._cworld = cworld
    world._context = context

    function world:create_entity(type)
        return iBuilding.create(self, type)
    end

    function world:fetch_entity(token)
        local proxy = token
        if type(token) == "number" then
            if not ecs:exist(token) then
                return
            end
            proxy = { eid = token }
        end
        local mt = {}
        function mt:__index(name)
            local t = proxy[name]
            if t == nil then
                t = ecs:access(token, name)
                if t == nil then
                    return
                end
                proxy[name] = t
            end
            if type(t) ~= "table" or ecs:type(name) ~= "c" then
                return t
            end
            local submt = {}
            submt.__index = t
            function submt:__newindex(k, v)
                if t[k] ~= v then
                    t[k] = v
                    ecs:access(token, name, t)
                end
            end
            return setmetatable({}, submt)
        end
        function mt:__newindex(name, value)
            proxy[name] = value
            ecs:access(token, name, value)
        end
        return setmetatable({}, mt)
    end

    local pipeline_init = pipeline(world, cworld, "init")
    local pipeline_update = pipeline(world, cworld, "update")
    local pipeline_build = pipeline(world, cworld, "build")
    local pipeline_backup = pipeline(world, cworld, "backup")
    local pipeline_restore = pipeline(world, cworld, "restore")

    function world:update()
        if cworld:is_dirty() then
            pipeline_build()
            cworld:reset_dirty()
        end
        pipeline_update()
        self._frame = self._frame + 1
    end
    function world:backup(rootdir)
        assert(not cworld:is_dirty())
        local fs = require "bee.filesystem"
        fs.create_directories(rootdir)
        world.storage_path = rootdir
        pipeline_backup()
    end
    function world:restore(rootdir)
        world.storage_path = rootdir
        pipeline_restore()
        iBuilding.dirty_restore(self)
        pipeline_build()
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

    function world:stat_dataset()
        return cworld:stat_dataset()
    end
    function world:stat_total(dataset, type)
        return cworld:stat_total(dataset, type)
    end
    function world:stat_query(dataset, type, id)
        return cworld:stat_query(dataset, type, id)
    end

    function world:fluidflow_query(fluid, id)
        return cFluidflow.query(cworld, fluid, id)
    end
    function world:now()
        return self._frame
    end

    --TOOD: 如果可以提前得知需要读档，这个操作是可以省略的
    prototype.restore(cworld, {})

    pipeline_init()
    return world
end
