local fs = require "filesystem"

local system_funcs = {}
for file in fs.pairs(fs.path "/pkg/vaststars.gamerender/gameplay/system/") do
    local s = file:stem():string()
    if s ~= "init" then
        system_funcs[s] = require("gameplay.system." .. s)
    end
end

local function update(world, get_vsobject_func)
    for _, func in pairs(system_funcs) do
        func(world, get_vsobject_func)
    end
end
return update