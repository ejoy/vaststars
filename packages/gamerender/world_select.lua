local ecs = ...
local world = ecs.world
local w = world.w

local function world_select(pat)
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

return world_select