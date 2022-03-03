local gameplay = import_package "vaststars.gameplay"
local world = gameplay.createWorld()
local m = {}

function m.select(...)
    return world.ecs:select(...)
end

function m.build(...)
    return world:build()
end
return m