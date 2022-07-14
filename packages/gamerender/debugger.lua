local fs = require "filesystem"
local debugger
if fs.exists(fs.path("/pkg/vaststars.prototype/debugger.lua")) then
    debugger = import_package "vaststars.prototype"("debugger")
end

local M = {}

function M.recipe_unlocked()
    if not debugger then
        return false
    end
    return debugger.recipe_unlocked
end

function M.infinite_item()
    if not debugger then
        return false
    end
    return debugger.infinite_item
end

return M