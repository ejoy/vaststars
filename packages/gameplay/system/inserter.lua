local prototype = require "prototype"
local system = require "register.system"

local s = system "inserter"

function s.build(world)
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
            v.inserter.input_container = inChest
            v.inserter.output_container = outChest
        else
            v.inserter.input_container = 0xFFFF --TODO
            v.inserter.output_container = 0xFFFF
        end
    end
end
