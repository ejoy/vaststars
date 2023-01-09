local fs = require "filesystem"

local system_funcs = {}
for file in fs.pairs(fs.path "/pkg/vaststars.gamerender/gameplay/update") do
    local s = file:stem():string()
    if s ~= "init" then
        system_funcs[s] = require("gameplay.update." .. s)
    end
end

local function update(world)
    for _, func in pairs(system_funcs) do
        func(world)
    end
end
return update