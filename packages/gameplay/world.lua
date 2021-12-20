require "register.types"

local status = require "status"
local prototype = require "prototype"
local timer = require "timer"
local vaststars = require "vaststars.world.core"
local ecs = import_package "vaststars.ecs"
local serialize = import_package "ant.serialize"
local datalist = require "datalist"

local function pipelineFunc(g, name)
    local p = status.pipelines[name]
    if not p then
        return
    end
    local world = g.world
    local cworld = g.cworld
    local systems = status.systems
    local csystems = status.csystems
    local funcs = {}
    for _, stage in ipairs(p) do
        for _, s in pairs(csystems) do
            if s[stage] then
                funcs[#funcs+1] = function()
                    return s[stage](cworld)
                end
            end
        end
        for _, s in pairs(systems) do
            if s[stage] then
                funcs[#funcs+1] = function()
                    return s[stage](world)
                end
            end
        end
    end
    local n = #funcs
    return function ()
        for i = 1, n do
            funcs[i]()
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
    local game = {}
    local world = ecs.world()
    world:register {
        name = "description",
        type = "lua"
    }
    local components = {}
    for _, c in ipairs(status.components) do
        assert(c.type == nil)
        world:register(c)
        components[#components+1] = c.name
    end
    local context = world:context(components)
    local ptable = require "vaststars.prototype.core"
    local cworld = vaststars.create_world(context, ptable)
    game.world = world
    game.cworld = cworld
    game.ecs_context = context

    function game.create_entity(type)
        return function (init)
            local typeobject = assert(prototype.query("entity", type))
            local types = typeobject.type
            local obj = {}
            for i = 1, #types do
                local ctor = status.ctor[types[i]]
                if ctor then
                    for k, v in pairs(ctor(game, init, typeobject)) do
                        if obj[k] == nil then
                            obj[k] = v
                        end
                    end
                end
            end
            obj.description = init.description
            return world:new(obj)
        end
    end

    local updateFunc = pipelineFunc(game, "update")
    function game.update()
        updateFunc()
        timer.update(1)
        world:update()
    end

    local rebuildFunc = pipelineFunc(game, "rebuild")
    function game.rebuild()
        rebuildFunc()
        world:update()
    end

    function game.backup()
        local sav = {}
        for v in world:select "entity" do
            local e = deepcopy(world:readall(v))
            e[1] = nil
            e[2] = nil
            sav[#sav+1] = e
        end
        return serialize.stringify(sav)
    end

    function game.restore(sav)
        sav = datalist.parse(sav)
        world:clearall()
        for _, e in ipairs(sav) do
            world:new(e)
        end
        world:update()
    end

    game.wait = timer.wait
    game.loop = timer.loop
    return game
end
