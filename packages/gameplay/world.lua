require "register.types"

local status = require "status"
local prototype = require "prototype"
local timer = require "timer"
local ecs = import_package "vaststars.ecs"
local vaststars = require "vaststars.world.core"

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

return function ()
    local game = {}
    local world = ecs.world()
    world:register {
        name = "debug",
        type = "lua"
    }
    for _, c in pairs(status.components) do
        world:register(c)
    end
    local context = world:context {
        "capacitance",
        "consumer",
        "generator",
        "accumulator",
        "entity",
        "bunker",
        "assembling",
        "inserter",
    }
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
                        obj[k] = v
                    end
                end
            end
            obj.debug = init
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

    game.wait = timer.wait
    game.loop = timer.loop
    return game
end
