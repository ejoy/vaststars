local fs = require "filesystem"
local debugger
local fn = "/pkg/vaststars.prototype/debugger.lua"
if fs.exists(fs.path(fn)) then
    debugger = import_package "vaststars.prototype"("debugger")
end

local options = {
    ["skip_guide"] = true,
    ["recipe_unlocked"] = true,
    ["infinite_item"] = true,
    ["disable_fps"] = true,
    ["disable_loading"] = true,
    ["disable_load_resource"] = true,
}

local function realtime_get(k)
    local t
    if fs.exists(fs.path(fn)) then
        local func, err = loadfile(fn)
        if not func then
            error(("error loading file '%s':\n\t%s"):format(fn, err))
        end
        t = func()
    end
    if not t then
        return
    end
    return t[k]
end

return setmetatable({realtime_get = realtime_get}, { __index = function (_, k)
    if not debugger then
        return false
    end
    if debugger.enable and options[k] then
        return true
    end
    return debugger[k]
end })
