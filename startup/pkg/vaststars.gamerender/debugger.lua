local fs = require "filesystem"
local debugger
local fn = "/pkg/vaststars.prototype/debugger.lua"
if fs.exists(fs.path(fn)) then
    debugger = import_package "vaststars.prototype"("debugger")
else
    debugger = {}
end

local options = {
    ["skip_guide"] = true,
    ["recipe_unlocked"] = true,
    ["infinite_item"] = true,
}

local free_mode = {
    ["skip_guide"] = true,
    ["recipe_unlocked"] = true,
    ["item_unlocked"] = true,
    ["infinite_item"] = true,
}

local function get(k)
    if not fs.exists(fs.path(fn)) then
        log.error(("can not found file '%s'"):format(fn))
        return
    end

    local func, err = loadfile(fn)
    if not func then
        log.error(("error loading file '%s':\n\t%s"):format(fn, err))
        return
    end

    local t = func()
    if not t then
        log.error(("error loading file '%s':\n\t%s"):format(fn, err))
        return
    end

    return t[k]
end

local function call(k, ...)
    local v = get(k)
    if not v then
        return
    end

    local ok, msg = xpcall(v, debug.traceback, ...)
    if not ok then
        log.error(("failed to call function '%s':\n\t%s"):format(k, msg))
        return
    end

    log.info(("call function '%s' success"):format(k))
end

local function set_free_mode(b)
    debugger.free_mode = b
end

return setmetatable({get = get, call = call, set_free_mode = set_free_mode}, { __index = function (_, k)
    if not debugger then
        return false
    end
    if debugger.enable and options[k] then
        return true
    end
    if debugger.free_mode and free_mode[k] then
        return true
    end
    return debugger[k]
end })
