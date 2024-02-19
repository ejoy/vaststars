local system = require "register.system"
local cFluidflow = require "vaststars.fluidflow.core"
local prototype = require "prototype"
local query = prototype.queryById

local kDirtyFluidflow       <const> = 1 << 2

local m = system "fluidflow"

local mt = {}
mt.__index = function (t, k)
    t[k] = setmetatable({}, mt)
    return t[k]
end

local builder = {}

local N <const> = 0
local E <const> = 1
local S <const> = 2
local W <const> = 3

local IN <const> = 0
local OUT <const> = 1
local INOUT <const> = 2

local UPS <const> = 30

local PipeEdgeType <const> = {
    ["input"] = IN,
    ["output"] = OUT,
    ["input-output"] = INOUT,
}
local PipeDirection <const> = {
    ["N"] = 0,
    ["E"] = 1,
    ["S"] = 2,
    ["W"] = 3,
}

local function is_pipeid(pt)
    for _, t in ipairs(pt.type) do
        if t == "pipe" or t == "pipe_to_ground" then
            return true
        end
    end
    return false
end

local function uniquekey(x, y, d)
    if d == N then
        d = "N"
    elseif d == E then
        x = x + 1
        d = "W"
    elseif d == S then
        y = y + 1
        d = "N"
    elseif d == W then
        d = "W"
    end
    return ("%d,%d,%s"):format(x, y, d)
end

local function rotate(position, direction, area)
    local w, h = area >> 8, area & 0xFF
    local x, y = position[1], position[2]
    local dir = (PipeDirection[position[3]] + direction) % 4
    w = w - 1
    h = h - 1
    if direction == N then
        return x, y, dir
    elseif direction == E then
        return h - y, x, dir
    elseif direction == S then
        return w - x, h - y, dir
    elseif direction == W then
        return y, w - x, dir
    end
end

local function calc_pipebits(pt, direction)
    local bits = 0
    for _, c in ipairs(pt.fluidbox.connections) do
        local dir = (PipeDirection[c.position[3]] + direction) % 4
        bits = bits | ((c.ground and 2 or 1) << (dir * 2))
    end
    return bits
end

local function builder_init()
    builder = {}
end

local function builder_build(world, fluid, fluidbox, limit)
    local pumping_speed = fluidbox.pumping_speed
    if pumping_speed then
        pumping_speed = pumping_speed // UPS
    end
    local capacity = limit or fluidbox.capacity
    assert(capacity > 0)
    return cFluidflow.build(world._cworld, fluid, capacity, fluidbox.height, fluidbox.base_level, pumping_speed)
end

local function connect(connects, a_id, a_type, b_id, b_type)
    local from, to
    local oneway = true
    if a_type ~= IN and b_type ~= OUT then
        from = a_id
        to = b_id
    end
    if b_type ~= IN and a_type ~= OUT then
        if from then
            oneway = false
        else
            from = b_id
            to = a_id
        end
    end
    if from then
        connects[#connects+1] = from
        connects[#connects+1] = to
        connects[#connects+1] = oneway
    end
end

local function builder_connect(c, key, id, type, eid, conndir)
    local neighbor = c.map[key]
    if not neighbor then
        c.map[key] = { id = id, type = type, eid = eid, conndir = conndir }
        return
    end
    connect(c.connects, id, type, neighbor.id, neighbor.type)
    c.map[key] = nil
end

local function builder_connect_fluidbox(fluid, id, fluidbox, eid, entity, area)
    local c = builder[fluid]
    if not c then
        c = {
            map = {},
            connects = {},
            ground = {},
        }
        builder[fluid] = c
    end
    assert(#fluidbox.connections <= 4)
    for _, conn in ipairs(fluidbox.connections) do
        local x, y, dir = rotate(conn.position, entity.direction, area)
        x = entity.x + x
        y = entity.y + y
        if conn.ground then
            local key = (y << 8)|x
            local t = c.ground[key]
            if not t then
                t = {
                    id = id,
                    x = x,
                    y = y,
                    connections = {}
                }
                c.ground[key] = t
            end
            t.connections[dir] = {
                type = PipeEdgeType[conn.type],
                max = conn.ground,
            }
        else
            local key = uniquekey(x, y, dir)
            builder_connect(c, key, id, PipeEdgeType[conn.type], eid, dir)
        end
    end
end

local function builder_groud(c)
    local function move(d)
        if d == N then
            return 0, -1
        elseif d == E then
            return 1, 0
        elseif d == S then
            return 0, 1
        elseif d == W then
            return -1, 0
        end
    end
    local function reverse(d)
        if d == N then
            return S
        elseif d == E then
            return W
        elseif d == S then
            return N
        elseif d == W then
            return E
        end
    end
    local function find_neighbor(x,y,dir,conn)
        local dx, dy = move(dir)
        for _ = 1, conn.max do
            x,y = x+dx, y+dy
            if x < 0 or y < 0 or x > 255 or y > 255 then
                return
            end
            local key = (y<<8)|x
            local t = c.ground[key]
            if t then
                if t.connections[dir] then
                    return
                end
                local rdir = reverse(dir)
                local rconn = t.connections[rdir]
                if rconn then
                    if rconn == true then
                        return
                    end
                    if rconn.max ~= conn.max then
                        return
                    end
                    t.connections[rdir] = true
                    return t.id, rconn.type
                end
            end
        end
    end
    for key, t in pairs(c.ground) do
        for dir, conn in pairs(t.connections) do
            if conn ~= true then
                local neighbor_id, neighbor_type = find_neighbor(key & 0xff, key >> 8, dir, conn)
                if neighbor_id then
                    t.connections[dir] = true
                    connect(c.connects, t.id, conn.type, neighbor_id, neighbor_type)
                end
            end
        end
    end
end

local function builder_finish(world)
    local finish = true
    for fluid, c in pairs(builder) do
        builder_groud(c)
        cFluidflow.connect(world._cworld, fluid, c.connects)
        if finish and next(c.map) ~= nil then
            finish = false
        end
    end
    if finish then
        return
    end
    -- handling disconnected pipes
    local pipebits = setmetatable({}, mt)
    local rev_pipebits = setmetatable({}, mt)
    for _, pt in pairs(prototype.all()) do
        if is_pipeid(pt) then
            for _, dir in pairs(pt.building_direction) do
                local bits = calc_pipebits(pt, PipeDirection[dir])
                assert(rawget(pipebits[pt.id], dir) == nil)
                pipebits[pt.id][PipeDirection[dir]] = bits
                assert(rawget(rev_pipebits[pt.building_category], bits) == nil)
                rev_pipebits[pt.building_category][bits] = {id = pt.id, direction = PipeDirection[dir]}
            end
        end
    end
    for _, c in pairs(builder) do
        for _, v in pairs(c.map) do
            local e = assert(world:fetch_entity(v.eid))
            local pt = query(e.building.prototype)
            if is_pipeid(pt) then
                local bits = assert(pipebits[e.building.prototype][e.building.direction])
                bits = bits & ~(3 << (v.conndir*2))
                local r = assert(rev_pipebits[pt.building_category][bits])
                e.building.prototype = r.id
                e.building.direction = r.direction
                e.building_changed = true
            end
        end
    end
end

local function teardown(w, fluid, id)
    if id ~= 0 then
        cFluidflow.teardown(w._cworld, fluid, id)
    end
end

function m.clean(world)
    if not world._cworld:is_dirty(kDirtyFluidflow) then
        return
    end
    local ecs = world.ecs
    for v in ecs:select "REMOVED fluidbox:in" do
        local fluid = v.fluidbox.fluid
        local id = v.fluidbox.id
        teardown(world, fluid, id)
    end
    for v in ecs:select "REMOVED fluidboxes:in" do
        for i = 1, 4 do
            local fluid = v.fluidboxes["in"..i.."_fluid"]
            if fluid ~= 0 then
                local id = v.fluidboxes["in"..i.."_id"]
                teardown(world, fluid, id)
            end
        end
        for i = 1, 3 do
            local fluid = v.fluidboxes["out"..i.."_fluid"]
            if fluid ~= 0 then
                local id = v.fluidboxes["out"..i.."_id"]
                teardown(world, fluid, id)
            end
        end
    end
end

function m.build(world)
    if not world._cworld:is_dirty(kDirtyFluidflow) then
        return
    end
    local ecs = world.ecs
    builder_init()
    for v in ecs:select "fluidbox:update building:in eid:in" do
        local pt = query(v.building.prototype)
        local fluid = v.fluidbox.fluid
        local id = v.fluidbox.id
        if id == 0 then
            id = builder_build(world, fluid, pt.fluidbox)
            v.fluidbox.id = id
        end
        builder_connect_fluidbox(fluid, id, pt.fluidbox, v.eid, v.building, pt.area)
    end
    for v in ecs:select "fluidboxes:update building:in eid:in" do
        local pt = query(v.building.prototype)
        local function init_fluidflow(classify)
            for i, fluidbox in ipairs(pt.fluidboxes[classify.."put"]) do
                local fluid = v.fluidboxes[classify..i.."_fluid"]
                if fluid ~= 0 then
                    local id = v.fluidboxes[classify..i.."_id"]
                    if id == 0 then
                        id = builder_build(world, fluid, fluidbox, v.fluidboxes[classify..i.."_limit"])
                        v.fluidboxes[classify..i.."_id"] = id
                    end
                    builder_connect_fluidbox(fluid, id, fluidbox, v.eid, v.building, pt.area)
                end
            end
        end
        init_fluidflow "in"
        init_fluidflow "out"
    end
    builder_finish(world)
end
