local fs = require "filesystem"
local debugger
if fs.exists(fs.path("/pkg/vaststars.prototype/debugger.lua")) then
    debugger = import_package "vaststars.prototype"("debugger")
end

local options = {
    ["skip_guide"] = true,
    ["recipe_unlocked"] = true,
    ["infinite_item"] = true,
    ["disable_fps"] = true,
    ["disable_loading"] = true,
}

return setmetatable({}, { __index = function (_, k)
    if not debugger then
        return false
    end
    if debugger.enable and options[k] then
        return true
    end
    return debugger[k]
end })
