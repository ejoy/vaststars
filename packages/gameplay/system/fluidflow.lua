
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
    local function rotate_(x, y, d)
        if d == N then
            return x, y
        elseif d == E then
            return -y, x
        elseif d == S then
            return -x, -y
        elseif d == W then
            return y, -x
        end
    end
    local w, h = area & 0xFF, area >> 8
    local dw, dh = w//2, h//2
    local x, y = position[1], position[2]
    x, y = x - dw, y - dh
    x, y = rotate_(x, y, direction)
    x, y = x + dw, y + dh
    local dir = (PipeDirection[position[3]] + direction) % 4
    return x, y, dir
end

local function builder_init()
    builder = {}
end

local function builder_build(world, fluid, fluidbox, capacity)
    return world:fluidflow_build(fluid, capacity, fluidbox.height, fluidbox.base_level, fluidbox.pumping_speed)
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
        local id = builder_build(world, v.fluidbox.fluid, pt.fluidbox, pt.fluidbox.capacity)
        local fluid = v.fluidbox.fluid
        v.fluidbox.id = id
        for _, conn in ipairs(pt.fluidbox.connections) do
            local x, y, dir = rotate(conn.position, v.entity.direction, pt.area)
            builder_connect(fluid, v.entity.x + x, v.entity.y + y, dir, id, PipeEdgeType[conn.type])
        end
    end
    for v in ecs:select "fluidboxes:update entity:in assembling:in" do
        local pt = query(v.entity.prototype)
        local recipe = query(v.assembling.recipe)
        local k <const> = {
            ["in"] = "ingredients",
            ["out"] = "results",
        }
        local function recipe_limit(classify, i)
            local lst = v.assembling["fluidbox_"..classify]
            local index = (lst >> (4*(i-1))) & 0xF
            local _, amount = string.unpack("<I2I2", recipe[k[classify]], 4*(index-1)+1)
            return amount * 2
        end
        local function need_recipe_limit(fluidbox)
            for _, conn in ipairs(fluidbox.connections) do
                local type = PipeEdgeType[conn.type]
                if type == INOUT or type == OUT then
                    return false
                end
            end
            return true
        end
        local function init_fluidflow(classify)
            for i, fluidbox in ipairs(pt.fluidboxes[classify.."put"]) do
                local fluid = v.fluidboxes[classify..i.."_fluid"]
                if fluid ~= 0 then
                    local capacity = fluidbox.capacity
                    if need_recipe_limit(fluidbox) then
                        capacity = recipe_limit(classify, i)
                    end
                    local id = builder_build(world, fluid, fluidbox, capacity)
                    v.fluidboxes[classify..i.."_id"] = id
                    for _, conn in ipairs(fluidbox.connections) do
                        local x, y, dir = rotate(conn.position, v.entity.direction, pt.area)
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
