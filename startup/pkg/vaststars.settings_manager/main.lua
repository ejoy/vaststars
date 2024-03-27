local directory = require "directory"
local ARCHIVAL_BASE_DIR <const> = (directory.app_path() / "archiving/"):string()
local GLOBAL_SETTINGS_FILE <const> = ARCHIVAL_BASE_DIR .. "settings.json"

local json = import_package "ant.json"
local fastio = require "fastio"
local fs = require "bee.filesystem"

local function writeall(file, settings)
    local content = json.encode(settings)
    local parent = fs.path(file):parent_path()
    if not fs.exists(parent) then
        fs.create_directories(parent)
    end
    local f <close> = assert(io.open(file, "wb"))
    f:write(content)
end

local function readall(file)
    return json.decode(fastio.readall_s(file))
end

local function get(k, def)
    if not fs.exists(fs.path(GLOBAL_SETTINGS_FILE)) then
        return def
    end
    local settings = readall(GLOBAL_SETTINGS_FILE)
    if settings[k] == nil then
        return def
    end
    return settings[k]
end

local function set(k, v)
    local settings
    if fs.exists(fs.path(GLOBAL_SETTINGS_FILE)) then
        settings = readall(GLOBAL_SETTINGS_FILE)
    else
        settings = {}
    end
    settings[k] = v
    writeall(GLOBAL_SETTINGS_FILE, settings)
end

return {
    get = get,
    set = set,
}