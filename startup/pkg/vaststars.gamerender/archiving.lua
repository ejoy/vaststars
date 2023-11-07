local fs = require "bee.filesystem"
local json = import_package "ant.json"
local directory = require "directory"
local fastio = require "fastio"

local ARCHIVAL_BASE_DIR = (directory.app_path() / "archiving/"):string()
local PROTOTYPE_VERSION = 1

local function readall(file)
    return fastio.readall_s(file)
end

local function fetch_all_archiving(root)
    local r = {}
    if not fs.exists(root) then
        return r
    end

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
function m.list()
    return fetch_all_archiving(ARCHIVAL_BASE_DIR)
end

function m.path()
    return ARCHIVAL_BASE_DIR
end

function m.set_dir(path)
    if path then
        ARCHIVAL_BASE_DIR = path
    end
end

function m.set_version(version)
    PROTOTYPE_VERSION = version
end

return m