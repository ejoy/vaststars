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

local function readall(file)
    local f <close> = assert(io.open(file, "rb"))
    return f:read "a"
end

local function fetch_all_archiving(path)
    local r = {}
    for v in fs.pairs(path) do
        if fs.is_directory(v) then
            r[#r+1] = v:string()
        end
    end
    table.sort(r, function(a, b)
        return a:gsub("-", "") < b:gsub("-", "")
    end)
    return r
end

local m = {}
function m.check(index)
    local list = fetch_all_archiving(ARCHIVAL_BASE_DIR)
    if #list <= 0 then
        return false
    end

    local fullpath = list[index]

    if not fs.exists(fullpath) then
        log.warn(("`%s` not exists"):format(fullpath))
        list[index] = nil
        index = index - 1
        return false
    end

    local versionpath = fullpath .. "/version"
    if not fs.exists(versionpath) then
        log.warn(("`%s` not exists"):format(versionpath))
        list[index] = nil
        index = index - 1
        return false
    end

    local v = json.decode(readall(versionpath))
    if v.PROTOTYPE_VERSION ~= PROTOTYPE_VERSION then
        log.error(("Failed `%s` version `%s` current `%s`"):format(fullpath, list[index].version, PROTOTYPE_VERSION))
        return false
    else
        return true
    end
end

function m.last()
    local list = fetch_all_archiving(ARCHIVAL_BASE_DIR)
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
    return fetch_all_archiving(ARCHIVAL_BASE_DIR)
end

function m.path()
    return ARCHIVAL_BASE_DIR
end

return m