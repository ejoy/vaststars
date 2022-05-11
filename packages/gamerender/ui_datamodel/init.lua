local ecs = ...
local world = ecs.world
local w = world.w

local fs = require "filesystem"

local funcs = {}
for file in fs.pairs(fs.path "/pkg/vaststars.gamerender/ui_datamodel/") do
    local s = file:stem():string()
    if s ~= "init" then
        funcs[s .. ".rml"] = ecs.require("ui_datamodel." .. s)
    end
end

return function(filename)
    return funcs[filename]
end