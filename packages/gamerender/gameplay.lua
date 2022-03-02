local gameplay = import_package "vaststars.gameplay"
local world = gameplay.createWorld()
local t = {}

function t.select(...)
    return world.ecs:select(...)
end

function t.build(...)
    return world:build()
end
return t