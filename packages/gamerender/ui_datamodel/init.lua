local ecs = ...
local world = ecs.world
local w = world.w

local fs = require "filesystem"

local funcs = {}
for file in fs.pairs(fs.path "/pkg/vaststars.gamerender/ui_datamodel/") do
    local f = file:string()
    local s = file:stem():string()
    if s ~= "init" then
        local func, err = loadfile(f)
        if not func then
            error(("error loading file '%s':\n\t%s"):format(f, err))
        end
        funcs[s .. ".rml"] = func
    end
end

return function(filename)
    return funcs[filename]
end