local fs = require "bee.filesystem"
local json = import_package "ant.json"
local directory = require "directory"

local PROTOTYPE_VERSION <const> = import_package("vaststars.prototype")("version")
local CUSTOM_ARCHIVING <const> = require "debugger".custom_archiving
local ARCHIVAL_BASE_DIR
if not __ANT_RUNTIME__ and CUSTOM_ARCHIVING then
    ARCHIVAL_BASE_DIR = (fs.exe_path():parent_path() / CUSTOM_ARCHIVING):lexically_normal():string()
else
    ARCHIVAL_BASE_DIR = (directory.app_path "vaststars" / "archiving/"):string()
end
local ARCHIVING_CONFIG <const> = ARCHIVAL_BASE_DIR .. "archiving.json"

local function readall(file)
    local f <close> = assert(io.open(file, "rb"))
    return f:read "a"
end

local m = {}
function m.check(index)
    local list = json.decode(readall(ARCHIVING_CONFIG))
    if #list <= 0 then
        return false
    end

    local relative = list[index].dir
    local fullpath = fs.path(ARCHIVAL_BASE_DIR .. ("%s"):format(relative))

    if not fs.exists(fullpath) then
        log.warn(("`%s` not exists"):format(relative))
        list[index] = nil
        index = index - 1
        return false
    end

    local versionpath = fullpath / "version"
    if not fs.exists(versionpath) then
        log.warn(("`%s` not exists"):format(versionpath:string()))
        list[index] = nil
        index = index - 1
        return false
    end

    local v = json.decode(readall(versionpath:string()))
    if v.PROTOTYPE_VERSION ~= PROTOTYPE_VERSION then
        log.error(("Failed `%s` version `%s` current `%s`"):format(relative, list[index].version, PROTOTYPE_VERSION))
        return false
    else
        return true
    end
end

function m.last()
    if not fs.exists(fs.path(ARCHIVING_CONFIG)) then
        return
    end

    local list = json.decode(readall(ARCHIVING_CONFIG))
    if #list <= 0 then
        return false
    end

    local index = #list
    while index > 0 do
        local ok = m.check(index)
        if ok then
            break
        end
        index = index - 1
    end

    if index <= 0 then
        return
    end
    return index
end

function m.list()
    if not fs.exists(fs.path(ARCHIVING_CONFIG)) then
        return {}
    end
    return json.decode(readall(ARCHIVING_CONFIG))
end

function m.config()
    return ARCHIVING_CONFIG
end

function m.path()
    return ARCHIVAL_BASE_DIR
end

return m