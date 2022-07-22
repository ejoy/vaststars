local fs = require "filesystem"
local debugger
if fs.exists(fs.path("/pkg/vaststars.prototype/debugger.lua")) then
    debugger = import_package "vaststars.prototype"("debugger")
end

return setmetatable({}, { __index = function (_, k)
    if not debugger then
        return false
    end
    return debugger[k]
end })
