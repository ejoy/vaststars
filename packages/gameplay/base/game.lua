require "base.register.types"

local status = require "base.status"
local prototype = require "base.prototype"
local timer = require "base.timer"
local ecs = import_package "vaststars.ecs"
local vaststars = require "vaststars.world.core"
local w = ecs.world()
local m = {}
local _events = {}

w:register {
    name = "debug",
    type = "lua",
}

local updateFunction
local rebuildFunction

function m.init()
    for _, c in pairs(status.components) do
        w:register(c)
    end
    local rebuilds = {}
    local updates = {}
    for _, s in pairs(status.systems) do
        updates[#updates+1] = function()
            return s:update(w)
        end
    end
    local context = w:context {
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
    local world = vaststars.create_world(context, ptable)
    m.world = world
    m.ecs_context = context
    for name in pairs(status.csystems) do
        local s = require(name)
        do
            local f = s.update
            if f then
                updates[#updates+1] = function()
                    return f(world)
                end
            end
        end
        do
            local f = s.rebuild
            if f then
                rebuilds[#rebuilds+1] = function()
                    return f(world)
                end
            end
        end
    end
    do
        local n = #updates
        function updateFunction()
            for i = 1, n do
                updates[i]()
            end
        end
    end
    do
        local n = #rebuilds
        function rebuildFunction()
            for i = 1, n do
                rebuilds[i]()
            end
        end
    end
end

function m.create_entity(type)
    return function (init)
        local typeobject = assert(prototype.query("entity", type))
        local types = typeobject.type
        local obj = {}
        for i = 1, #types do
            local ctor = status.ctor[types[i]]
            if ctor then
                for k, v in pairs(ctor(w, init, typeobject)) do
                    obj[k] = v
                end
            end
        end
        obj.debug = init
        return w:new(obj)
    end
end

function m.event(name, ...)
    local event = _events[name]
    if event then
        for i = 1, #event do
            event[i](w, ...)
        end
    end
end

function m.on(name, f)
    local event = _events[name]
    if event then
        event[#event+1] = f
    else
        _events[name] = {f}
    end
end

function m.update()
    updateFunction()
    timer.update(1)
    w:update()
end

function m.rebuild()
    m.event "rebuild"
    rebuildFunction()
    w:update()
end

m.wait = timer.wait
m.loop = timer.loop
m.w = w

return m
