local prototype = require "prototype"
local type = require "register.type"
local system = require "register.system"

local STATUS_IN <const> = 0
local STATUS_OUT <const> = 1

local c = type "inserter"
    .speed "time"

function c:ctor(_, pt)
    return {
        inserter = {
            input_container = 0xFFFF,
            output_container = 0xFFFF,
            hold_item = 0,
            hold_amount = 0,
            process = 0,
            low_power = 0,
            status = STATUS_IN,
        }
    }
end

local function what_status(e)
    --TODO
    --  no_power
    --  disabled
    --  no_minable_resources
    local i = e.inserter
    if i.input_container == 0xFFFF or i.output_container == 0xFFFF then
        return "idle"
    end
    if i.process <= 0 then
        if i.status == STATUS_IN then
            return "insufficient_input"
        elseif i.status == STATUS_OUT then
            return "full_output"
        end
    end
    if i.low_power ~= 0 then
        return "low_power"
    end
    return "working"
end

local s = system "inserter"

function s.init(world)
    local ecs = world.ecs
    local ChestMap = {}
    local function packCoord(x, y)
        return x | (y<<8)
    end
    local function unpackCoord(v)
        return v >> 8, v & 0xFF
    end
    local function setContainer(entity, id)
        local pt = prototype.queryById(entity.prototype)
        local x, y = entity.x, entity.y
        local w, h = unpackCoord(pt.area)
        for i = 0, w-1 do
            for j = 0, h-1 do
                ChestMap[packCoord(x+i, y+j)] = id
            end
        end
    end
    for v in ecs:select "chest:in entity:in" do
        setContainer(v.entity, v.chest.container)
    end
    for v in ecs:select "assembling:in entity:in" do
        setContainer(v.entity, v.assembling.container)
    end
    for v in ecs:select "inserter:update entity:in" do
        local x, y = v.entity.x, v.entity.y
        local sx, sy, ex, ey
        if v.entity.direction == 0 then --N
            sx, sy = 0, -1
            ex, ey = 0, 1
        elseif v.entity.direction == 1 then --E
            sx, sy = 1, 0
            ex, ey = -1, 0
        elseif v.entity.direction == 2 then --S
            sx, sy = 0, 1
            ex, ey = 0, -1
        elseif v.entity.direction == 3 then --W
            sx, sy = -1, 0
            ex, ey = 1, 0
        end
        local inChest = ChestMap[packCoord(x + sx, y + sy)]
        local outChest = ChestMap[packCoord(x + ex, y + ey)]
        if inChest and outChest then
            v.inserter.process = 0
            v.inserter.status = 0
            v.inserter.input_container = inChest
            v.inserter.output_container = outChest
        else
            v.inserter.input_container = 0xFFFF --TODO
            v.inserter.output_container = 0xFFFF
        end
    end
end
