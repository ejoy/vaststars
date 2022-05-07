local ecs = ...
local world = ecs.world
local w = world.w

local fs = require "filesystem"

local system_funcs = {}
for file in fs.pairs(fs.path "/pkg/vaststars.gamerender/world_update/") do
    local s = file:stem():string()
    if s ~= "init" then
        system_funcs[s] = ecs.require("world_update." .. s)
    end
end

local function update(world, get_vsobject_func)
    for _, func in pairs(system_funcs) do
        func(world, get_vsobject_func)
    end
end
return update