
local system = require "register.system"
local query = require "prototype".queryById

local m = system "fluidflow"

local builder = {map={},connects = {}}

local N <const> = 0
local E <const> = 1
local S <const> = 2
local W <const> = 3

local IN <const> = 0
local OUT <const> = 1
local INOUT <const> = 2

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

local function uniquekey(x, y, d)
    if d == N then
        y = y + 1
        d = "S"
    elseif d == E then
        x = x + 1
        d = "W"
    elseif d == S then
        d = "S"
    elseif d == W then
        d = "W"
    end
    return ("%d,%d,%s"):format(x, y, d)
end

local function builder_init()
    builder = {}
end

local function builder_build(world, fluid, fluidbox)
    return world:fluidflow_build(fluid, fluidbox.area, fluidbox.height, fluidbox.base_level, fluidbox.pumping_speed)
end

local function builder_connect(fluid, x, y, dir, id, type)
    local c = builder[fluid]
    if not c then
        c = {
            map = {},
            connects = {},
        }
        builder[fluid] = c
    end
    local key = uniquekey(x, y, dir)
    local neighbor = c.map[key]
    if not neighbor then
        c.map[key] = { id = id, type = type }
        return
    end
    if type ~= OUT and neighbor.type ~= IN then
        c.connects[#c.connects+1] = id
        c.connects[#c.connects+1] = neighbor.id
    end
    if neighbor.type ~= OUT and type ~= IN then
        c.connects[#c.connects+1] = neighbor.id
        c.connects[#c.connects+1] = id
    end
    c.map[key] = nil
end

local function builder_finish(world)
    for fluid, c in pairs(builder) do
        world:fluidflow_connect(fluid, c.connects)
    end
end

function m.build(world)
    local ecs = world.ecs
    world:fluidflow_reset()
    builder_init()
    for v in ecs:select "pipe:update entity:in" do
        local pt = query(v.entity.prototype)
        local id = builder_build(world, v.pipe.fluid, pt.fluidbox)
        v.pipe.id = id
        for i = 0, 3 do
            if v.pipe.type & (1 << i) ~= 0 then
                builder_connect(v.pipe.fluid, v.entity.x, v.entity.y, i, id, INOUT)
            end
        end
    end
    for v in ecs:select "fluidboxes:update entity:in" do
        local pt = query(v.entity.prototype)
        for i, fluidbox in ipairs(pt.fluidboxes.input) do
            local fluid = v.fluidboxes["in"..i] >> 16
            if fluid ~= 0 then
                local id = builder_build(world, fluid, fluidbox)
                v.fluidboxes["in"..i] = (fluid << 16) | id
                for _, pipe in ipairs(fluidbox.pipe) do
                    local x = v.entity.x + pipe.position[1]
                    local y = v.entity.y + pipe.position[2]
                    builder_connect(fluid, x, y, PipeDirection[pipe.position[3]], id, PipeEdgeType[pipe.type])
                end
            end
        end
    end
    builder_finish(world)
end
