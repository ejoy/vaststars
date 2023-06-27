local m = {}

local DirtyUnknown   <const> = 1 << 1
local DirtyRoadnet   <const> = 1 << 2
local DirtyFluidflow <const> = 1 << 3
local DirtyHub       <const> = 1 << 4
local DirtyTech      <const> = 1 << 5
local DirtyStationProducer <const> = 1 << 6
local DirtyStationConsumer <const> = 1 << 7

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

local function dirty_changed_entity(world, e)
    if e.road or e.endpoint or e.starting then
        world:dirty(DirtyRoadnet)
    end
    if e.fluidbox or e.fluidboxes then
        e.fluidbox_changed = true
        world:dirty(DirtyFluidflow)
    end
    if e.chest or e.hub then
        world:dirty(DirtyHub)
    end
end

local function dirty_entity(world, e)
    dirty_changed_entity(world, e)
    if e.station_producer then
        world:dirty(DirtyStationProducer)
    end
    if e.station_consumer then
        world:dirty(DirtyStationConsumer)
    end
end

function m.create(world, e)
    dirty_entity(world, e)
end

function m.dirty(world, what)
    world:dirty(DIRTY[what])
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
