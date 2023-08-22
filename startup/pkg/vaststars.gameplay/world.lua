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

    local context = ecs:context()
    local cworld = cWorld.create_world(context)
    world.ecs = ecs
    world._cworld = cworld
    world._context = context

    --TOOD: 如果可以提前得知需要读档，这个操作是可以省略的
    prototype.restore(cworld, {})

    function world:create_entity(type)
        return iBuilding.create(self, type)
    end

    local visitor = {}
    local function visitor_create()
        local proxy_mt = {}
        function proxy_mt:__index(name)
            local eid = self.eid
            local t = ecs:access(eid, name)
            if type(t) ~= "table" or ecs:type(name) ~= "c" then
                return t
            end
            local mt = {}
            mt.__index = t
            function mt:__newindex(k, v)
                if t[k] ~= v then
                    t[k] = v
                    ecs:access(eid, name, t)
                end
            end
            return setmetatable({}, mt)
        end
        function proxy_mt:__newindex(name, value)
            ecs:access(self.eid, name, value)
        end
        local visitor_mt = {}
        function visitor_mt:__index(eid)
            if not ecs:exist(eid) then
                return
            end
            local proxy = setmetatable({eid=eid}, proxy_mt)
            visitor[eid] = proxy
            return proxy
        end
        return setmetatable(visitor, visitor_mt)
    end
    function world:visitor_update()
        for e in ecs:select "REMOVED eid:in" do
            visitor[e.eid] = nil
        end
    end
    function world:visitor_clear()
        for eid in pairs(visitor) do
            visitor[eid] = nil
        end
    end
    world.entity = visitor_create()

    local pipeline_init = pipeline(world, cworld, "init")
    local pipeline_update = pipeline(world, cworld, "update")
    local pipeline_build = pipeline(world, cworld, "build")
    local pipeline_backup = pipeline(world, cworld, "backup")
    local pipeline_restore = pipeline(world, cworld, "restore")

    pipeline_init()

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
        cworld:reset_dirty()
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
        return cFluidflow.query(cworld, fluid, id)
    end
    function world:container_get(c, i)
        return iChest.get(self, c, i)
    end
    function world:container_set(c, i, t)
        return iChest.set(self, c, i, t)
    end
    function world:now()
        return self._frame
    end

    return world
end
