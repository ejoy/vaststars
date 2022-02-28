local ecs = ...
local world = ecs.world
local w = world.w

return function(get_entity_func, x, y, dir, area)
    if get_entity_func(x, y) == nil then
        return true
    else
        return false
    end
end