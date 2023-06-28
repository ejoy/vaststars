local cBackpack = require "vaststars.backpack.core"

local m = {}

function m.pickup(world, item, amount)
    return cBackpack.pickup(world._cworld, item, amount)
end

function m.place(world, item, amount)
    return cBackpack.place(world._cworld, item, amount)
end

function m.query(world, item)
    return cBackpack.query(world._cworld, item)
end

function m.all(world)
    local ecs = world.ecs
    local n = ecs:count "backpack"
    local t = {}
    for i = 1, n do
        local bp = ecs:object("backpack", i)
        if bp.item == 0 then
            break
        end
        t[i] = bp
    end
    return t
end

return m
