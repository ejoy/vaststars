local system = require "register.system"
local query = require "prototype".queryById

local m = system "electricpole"

local function hasPower(Map, e)
    local pt = query(e.entity.prototype)
    local x, y = e.entity.x, e.entity.y
    local w, h = pt.area >> 8, pt.area & 0xFF
    for i = x, x+w-1 do
        for j = y, y+h-1 do
            if Map[i*1000+j] then
                return true
            end
        end
    end
end

function m.build(world)
    local ecs = world.ecs
    local Map = {}
    ecs:clear "power"
    for e in ecs:select "pole entity:in" do
        local pt = query(e.entity.prototype)
        local x, y = e.entity.x, e.entity.y
        local w, h = pt.area >> 8, pt.area & 0xFF
        local sw, sh = pt.supply_area >> 8, pt.supply_area & 0xFF
        local sx, sy = x - (sw-w)//2, y - (sh-h)//2
        for i = sx, sx+sw-1 do
            for j = sy, sy+sh-1 do
                Map[i*1000+j] = true
            end
        end
    end
    for e in ecs:select "capacitance entity:in power:new" do
        e.power = hasPower(Map, e)
    end
end
