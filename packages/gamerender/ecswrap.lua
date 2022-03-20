local ecs = ...
local world = ecs.world
local w = world.w
local m = {}

function m.select(pat)
    local f, t, v = w:select(pat)
    return function(t, v)
        local e = f(t, v)
        if not e then
            return
        end
        w:sync("id:in", e)
        return e, world:entity(e.id)
    end, t, v
end

function m.singleton(name, pat)
    local e = w:singleton(name, pat)
    if not e then
        return
    end
    w:sync("id:in", e)
    return world:entity(e.id)
end

return m