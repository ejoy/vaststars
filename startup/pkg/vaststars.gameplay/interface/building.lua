local status = require "status"
local prototype = require "prototype"

local m = {}

local DirtyRoadnet         <const> = 1 << 1
local DirtyFluidflow       <const> = 1 << 2
local DirtyHub             <const> = 1 << 3
local DirtyStationProducer <const> = 1 << 4
local DirtyStationConsumer <const> = 1 << 5

local DIRTY <const> = {
    roadnet = DirtyRoadnet,
    fluidflow = DirtyFluidflow,
    hub = DirtyHub,
    station_producer = DirtyStationProducer,
    station_consumer = DirtyStationConsumer,
}

local DIRECTION <const> = {
    N = 0, North = 0,
    E = 1, East  = 1,
    S = 2, South = 2,
    W = 3, West  = 3,
}

local function dirty(world, flags)
    world._cworld:set_dirty(flags)
end

local function dirty_changed_entity(world, e)
    local flags = 0
    if e.road or e.endpoint or e.starting then
        flags = flags | DirtyRoadnet
    end
    if e.fluidbox or e.fluidboxes then
        flags = flags | DirtyFluidflow
    end
    if e.chest or e.hub then
        flags = flags | DirtyHub
    end
    if flags ~= 0 then
        dirty(world, flags)
    end
end

local function dirty_entity(world, e)
    local flags = 0
    if e.road or e.endpoint or e.starting then
        flags = flags | DirtyRoadnet
    end
    if e.fluidbox or e.fluidboxes then
        flags = flags | DirtyFluidflow
    end
    if e.chest or e.hub then
        flags = flags | DirtyHub
    end
    if e.station_producer then
        flags = flags | DirtyStationProducer
    end
    if e.station_consumer then
        flags = flags | DirtyStationConsumer
    end
    if flags ~= 0 then
        dirty(world, flags)
    end
end

function m.create(world, type)
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
        dirty_entity(world, obj)
        return world.ecs:new(obj)
    end
end

function m.dirty(world, what)
    dirty(world, DIRTY[what])
end

function m.dirty_restore(world)
    dirty(world,
          DirtyFluidflow
        | DirtyHub
        | DirtyStationProducer
        | DirtyStationConsumer
    )
end

function m.move(world, e, x, y)
    local building = e.building
    if building.x ~= x or building.y ~= y then
        building.x = x
        building.y = y
        dirty_changed_entity(world, e)
    end
end

function m.rotate(world, e, dir)
    local building = e.building
    local d = assert(DIRECTION[dir])
    if building.direction ~= d then
        building.direction = d
        dirty_changed_entity(world, e)
    end
end

function m.destroy(world, e)
    dirty_entity(world, e)
    -- ecs:remove 无法处理entity visitor
    e.REMOVED = true
end

return m
