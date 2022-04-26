local system = require "register.system"
local query = require "prototype".queryById

local m = system "fluidflow"

local builder = {}

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

local function builder_build(world, fluid, id, fluidbox)
    if id ~= 0 then
        world:fluidflow_rebuild(fluid, id)
        return
    end
    local pumping_speed = fluidbox.pumping_speed
    if pumping_speed then
        pumping_speed = pumping_speed // UPS
    end
    return world:fluidflow_build(fluid, fluidbox.capacity, fluidbox.height, fluidbox.base_level, pumping_speed)
end

local function builder_restore(world, fluid, id, fluidbox)
    local pumping_speed = fluidbox.pumping_speed
    if pumping_speed then
        pumping_speed = pumping_speed // UPS
    end
    return world:fluidflow_restore(fluid, id, fluidbox.capacity, fluidbox.height, fluidbox.base_level, pumping_speed)
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
    builder_init()
    for v in ecs:select "fluidbox:update entity:in fluidbox_changed?in" do
        local pt = query(v.entity.prototype)
        local fluid = v.fluidbox.fluid
        local id = v.fluidbox.id
        if v.fluidbox_changed then
            local newid = builder_build(world, fluid, id, pt.fluidbox)
            if newid then
                v.fluidbox.id = newid
                id = newid
            end
        else
            assert(id ~= 0)
        end
        builder_connect_fluidbox(fluid, id, pt.fluidbox, v.entity, pt.area)
    end
    for v in ecs:select "fluidboxes:update entity:in fluidbox_changed?in" do
        local pt = query(v.entity.prototype)
        local function init_fluidflow(classify)
            for i, fluidbox in ipairs(pt.fluidboxes[classify.."put"]) do
                local fluid = v.fluidboxes[classify..i.."_fluid"]
                if fluid ~= 0 then
                    local id = v.fluidboxes[classify..i.."_id"]
                    if v.fluidbox_changed then
                        local newid = builder_build(world, fluid, id, fluidbox)
                        if newid then
                            v.fluidboxes[classify..i.."_id"] = newid
                            id = newid
                        end
                    else
                        assert(id ~= 0)
                    end
                    builder_connect_fluidbox(fluid, id, fluidbox, v.entity, pt.area)
                end
            end
        end
        init_fluidflow "in"
        init_fluidflow "out"
    end
    builder_finish(world)
    ecs:clear "fluidbox_changed"
end

function m.backup_start(world)
    local ecs = world.ecs
    for v in ecs:select "fluidbox:in" do
        local fluid = v.fluidbox.fluid
        local id = v.fluidbox.id
        local volume = world:fluidflow_query(fluid, id).volume
        ecs:new {
            save_fluidflow = {
                fluid = fluid,
                id = id,
                volume = volume,
            }
        }
    end
end

function m.backup_finish(world)
    local ecs = world.ecs
    ecs:clear "save_fluidflow"
end

function m.restore_finish(world)
    local ecs = world.ecs
    builder_init()
    for v in ecs:select "fluidbox:in entity:in" do
        local pt = query(v.entity.prototype)
        local fluid = v.fluidbox.fluid
        local id = v.fluidbox.id
        builder_restore(world, fluid, id, pt.fluidbox)
        builder_connect_fluidbox(fluid, id, pt.fluidbox, v.entity, pt.area)
    end
    for v in ecs:select "fluidboxes:in entity:in" do
        local pt = query(v.entity.prototype)
        local function init_fluidflow(classify)
            for i, fluidbox in ipairs(pt.fluidboxes[classify.."put"]) do
                local fluid = v.fluidboxes[classify..i.."_fluid"]
                if fluid ~= 0 then
                    local id = v.fluidboxes[classify..i.."_id"]
                    builder_restore(world, fluid, id, fluidbox)
                    builder_connect_fluidbox(fluid, id, fluidbox, v.entity, pt.area)
                end
            end
        end
        init_fluidflow "in"
        init_fluidflow "out"
    end
    builder_finish(world)
    for v in ecs:select "save_fluidflow:in" do
        local sav = v.save_fluidflow
        world:fluidflow_set(sav.fluid, sav.id, sav.volume, 1)
    end
    ecs:clear "save_fluidflow"
end
