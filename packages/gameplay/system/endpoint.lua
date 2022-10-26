local system = require "register.system"
local query = require "prototype".queryById
local m = system "endpoint"

local DIRECTION <const> = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
    [0] = 'N',
    [1] = 'E',
    [2] = 'S',
    [3] = 'W',
}

local mapping = {
    W = 0, -- left
    N = 1, -- top
    E = 2, -- right
    S = 3, -- bottom
}

local function rotate(position, direction, area)
    local w, h = area >> 8, area & 0xFF
    local x, y = position[1], position[2]
    local dir = (DIRECTION[position[3]] + direction) % 4
    w = w - 1
    h = h - 1
    if direction == DIRECTION.N then
        return x, y, dir
    elseif direction == DIRECTION.E then
        return h - y, x, dir
    elseif direction == DIRECTION.S then
        return w - x, h - y, dir
    elseif direction == DIRECTION.W then
        return y, w - x, dir
    end
end

local function build(e, world)
    local pt = query(e.entity.prototype)
    if not pt.crossing then -- TODO: temporary code
        return
    end
    assert(#pt.crossing.connections == 1)
    local x, y, dir = rotate(pt.crossing.connections[1].position, e.entity.direction, pt.area)
    x = x + e.entity.x
    y = y + e.entity.y
    local endpoint = world.roadnet:create_endpoint(x, y, mapping[DIRECTION[dir]])
    if e.chest_2 then
        local chest = e.chest_2
        chest.endpoint = endpoint

        if chest.chest_in ~= 0xffff then
            world:container_flush(chest.chest_in, endpoint)
        end
        if chest.chest_out ~= 0xffff then
            world:container_flush(chest.chest_out, endpoint)
        end
    elseif e.station then
        e.station.endpoint = endpoint
        local l = world.roadnet:create_lorry()
        assert(endpoint ~= 0xffff)
        world.roadnet:place_lorry(endpoint, l)
    else
        assert(false)
    end
end

function m.pre_build(world)
    local ecs = world.ecs
    if ecs:first("road_changed:in") then -- TODO: remove this temporary code
        for e in ecs:select "chest_2:update entity:in" do
            build(e, world)
        end
        for e in ecs:select "station:update entity:in" do
            build(e, world)
        end
        ecs:clear "road_changed"
        ecs:clear "endpoint_changed"
        return
    end
    for e in ecs:select "endpoint_changed:in chest_2:update entity:in" do
        build(e, world)
    end
    for e in ecs:select "endpoint_changed:in station:update entity:in" do
        build(e, world)
    end
    ecs:clear "endpoint_changed"
end

function m.restore_finish(world)
    local ecs = world.ecs
    for e in ecs:select "chest_2:update entity:in" do
       build(e, world)
    end
    for e in ecs:select "station:update entity:in" do
        build(e, world)
    end
end