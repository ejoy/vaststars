
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

local function rotate(position, d)
    local x = position[1]
    local y = position[2]
    local dir = (PipeDirection[position[3]] + d) % 4
    if d == N then
        return x, y, dir
    elseif d == E then
        return y, -x, dir
    elseif d == S then
        return -x, -y, dir
    elseif d == W then
        return -y, x, dir
    end
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
    for v in ecs:select "fluidbox:update entity:in" do
        local pt = query(v.entity.prototype)
        local id = builder_build(world, v.fluidbox.fluid, pt.fluidbox)
        local fluid = v.fluidbox.fluid
        v.fluidbox.id = id
        for _, conn in ipairs(pt.fluidbox.connections) do
            local x, y, dir = rotate(conn.position, v.entity.direction)
            builder_connect(fluid, v.entity.x + x, v.entity.y + y, dir, id, PipeEdgeType[conn.type])
        end
    end
    for v in ecs:select "fluidboxes:update entity:in" do
        local pt = query(v.entity.prototype)
        local function init_fluidflow(classify)
            for i, fluidbox in ipairs(pt.fluidboxes[classify.."put"]) do
                local fluid = v.fluidboxes[classify..i.."_fluid"]
                if fluid ~= 0 then
                    local id = builder_build(world, fluid, fluidbox)
                    v.fluidboxes[classify..i.."_id"] = id
                    for _, conn in ipairs(fluidbox.connections) do
                        local x, y, dir = rotate(conn.position, v.entity.direction)
                        builder_connect(fluid, v.entity.x + x, v.entity.y + y, dir, id, PipeEdgeType[conn.type])
                    end
                end
            end
        end
        init_fluidflow "in"
        init_fluidflow "out"
    end
    builder_finish(world)

    for v in ecs:select "fluidbox:in fluidbox_build:in" do
        world:fluidflow_change(v.fluidbox.fluid, v.fluidbox.id, "import", v.fluidbox_build.volume)
    end
    ecs:clear "fluidbox_build"
end
