local fs = require "bee.filesystem"
local platform = require "bee.platform"
local vfs = require "vfs"
local ltask = require "ltask"
local zip = require "zip"

local version = import_package "vaststars.version"
local gameupdate = import_package "vaststars.gameupdate"
local compile_vfs = require "compile_vfs"
local create_zip = require "create_zip"
local download_patch = gameupdate.download_patch

local shortver = version.game:sub(1, 6)

print(("Ant Engine Version: %s."):format(version.engine))
print(("Game Core Version:  %s."):format(version.game))
print(("Short Version:      %s."):format(shortver))

local repopath <const> = fs.absolute "../../startup/":string()
local rootpath <const> = vfs.repopath()
local reskey <const> = platform.os == "windows" and  {
    "windows-direct3d11",
    --"ios-metal",
} or {
    "ios-metal",
}

for _ in ltask.parallel {
    { compile_vfs, repopath, reskey },
    { download_patch, fs.path(rootpath) / ".download", shortver, reskey },
} do
end

local function writeall(path, content)
    local f <close> = assert(io.open(path, "wb"))
    f:write(content)
end

local function read_zip_list(path, set)
    local f = assert(zip.open(path, "r"))
    local list = f:list()
    for _, v in ipairs(list) do
        set[v] = true
    end
end

local function fetch_core()
    local fileSet = {}
    for index = 0, 99 do
        local path = ("%s.download/core/%02d.zip"):format(rootpath, index)
        if not fs.exists(path) then
            return index, fileSet
        end
        read_zip_list(path, fileSet)
    end
    error "Too many patches."
end

local function fetch_res(key, n)
    local fileSet = {}
    for index = 0, n do
        local path = ("%s.download/%s/%02d.zip"):format(rootpath, key, index)
        if fs.exists(path) then
            read_zip_list(path, fileSet)
        end
    end
    return fileSet
end

local maxIndex, coreFileSet = fetch_core()
do
    local hash = create_zip(("%s.output/core/%02d.zip"):format(rootpath, maxIndex), repopath, {}, coreFileSet, {})
    writeall(("%s.output/core/%02d.hash"):format(rootpath, maxIndex), hash)
end

for _, key in ipairs(reskey) do
    local resFileSet = fetch_res(key, maxIndex-1)
    local hash = create_zip(("%s.output/%s/%02d.zip"):format(rootpath, key, maxIndex), repopath, { key }, coreFileSet, resFileSet)
    writeall(("%s.output/%s/%02d.hash"):format(rootpath, key, maxIndex), hash)
end
