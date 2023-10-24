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

local function fetch_all_archiving(root)
    if not fs.exists(root) then
        fs.create_directories(root)
    end

    local r = {}
    for path in fs.pairs(root) do
        if not fs.is_directory(path) then
            goto continue
        end

        local versionpath = path / "version"
        if not fs.exists(versionpath) then
            log.warn(("`%s` not exists"):format(versionpath))
            goto continue
        end

        local v = json.decode(readall(versionpath:string()))
        if v.PROTOTYPE_VERSION ~= PROTOTYPE_VERSION then
            log.error(("Failed `%s` version `%s` current `%s`"):format(path, v.PROTOTYPE_VERSION, PROTOTYPE_VERSION))
            goto continue
        end

        r[#r+1] = path:string()
        ::continue::
    end
    table.sort(r)
    return r
end

local m = {}
function m.last()
    local list = fetch_all_archiving(ARCHIVAL_BASE_DIR)
    if #list <= 0 then
        return
    end
    return #list
end

function m.list()
    return fetch_all_archiving(ARCHIVAL_BASE_DIR)
end

function m.path()
    return ARCHIVAL_BASE_DIR
end

return m