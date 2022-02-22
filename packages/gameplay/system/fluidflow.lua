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

local UPS <const> = 50

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

local function builder_init()
    builder = {}
end

local function builder_build(world, fluid, fluidbox, capacity)
    local pumping_speed = fluidbox.pumping_speed
    if pumping_speed then
        pumping_speed = pumping_speed // UPS
    end
    return world:fluidflow_build(fluid, capacity, fluidbox.height, fluidbox.base_level, pumping_speed)
end

local function builder_connect(c, key, id, type)
    local neighbor = c.map[key]
    if not neighbor then
        c.map[key] = { id = id, type = type }
        return
    end
    local from, to
    local oneway = true
    if type ~= IN and neighbor.type ~= OUT then
        from = id
        to = neighbor.id
    end
    if neighbor.type ~= IN and type ~= OUT then
        if from then
            oneway = false
        else
            from = neighbor.id
            to = id
        end
    end
    if from then
        c.connects[#c.connects+1] = from
        c.connects[#c.connects+1] = to
        c.connects[#c.connects+1] = oneway
    end
    c.map[key] = nil
end

local function builder_connect_fluidbox(fluid, id, fluidbox, entity, area)
    local c = builder[fluid]
    if not c then
        c = {
            map = {},
            connects = {},
        }
        builder[fluid] = c
    end
    for _, conn in ipairs(fluidbox.connections) do
        local x, y, dir = rotate(conn.position, entity.direction, area)
        local key = uniquekey(entity.x + x, entity.y + y, dir)
        builder_connect(c, key, id, PipeEdgeType[conn.type])
    end
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
        builder_connect_fluidbox(fluid, id, pt.fluidbox, v.entity, pt.area)
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
                    builder_connect_fluidbox(fluid, id, fluidbox, v.entity, pt.area)
                end
            end
        end
        init_fluidflow "in"
        init_fluidflow "out"
    end
    builder_finish(world)

    local function init_fluidbox(fluid, id, volume)
        if fluid ~= 0 and volume and volume > 0 then
            world:fluidflow_set(fluid, id, volume)
        end
    end
    for v in ecs:select "fluidbox:in init_fluidbox:in" do
        init_fluidbox(v.fluidbox.fluid, v.fluidbox.id, v.init_fluidbox)
    end
    for v in ecs:select "fluidboxes:in init_fluidbox:in" do
        local fb = v.fluidboxes
        local init = v.init_fluidbox
        init_fluidbox(fb.in1_fluid,  fb.in1_id,  init.in1)
        init_fluidbox(fb.in2_fluid,  fb.in2_id,  init.in2)
        init_fluidbox(fb.in3_fluid,  fb.in3_id,  init.in3)
        init_fluidbox(fb.in4_fluid,  fb.in4_id,  init.in4)
        init_fluidbox(fb.out1_fluid, fb.out1_id, init.out1)
        init_fluidbox(fb.out2_fluid, fb.out2_id, init.out2)
        init_fluidbox(fb.out3_fluid, fb.out3_id, init.out3)
    end
    ecs:clear "init_fluidbox"
end
