
import_package "ant.hwi".init_bgfx()
local version = import_package "vaststars.version"
local platform = require "bee.platform"
local fs = require "bee.filesystem"
local bgfx = require "bgfx"
local zip = require "zip"
local download_patch = require "download_patch"

local shortver <const> = version.game:sub(1, 6)

local function readall(filename)
    local f <close> = assert(io.open(filename:string(), "rb"))
    return f:read "a"
end

local function writeall(filename, data)
	local f <close> = assert(io.open(filename:string(), "wb"))
	f:write(data)
end

local function unzip(zippath, output)
    local f = assert(zip.open(zippath, "r"))
    for _, name in ipairs(f:list()) do
        if not fs.exists(output / name) then
            writeall(output / name, f:readfile(name))
        end
    end
    f:close()
end

local function app_path(name)
	if platform.os == "windows" then
		return fs.path(os.getenv "LOCALAPPDATA") / name
	elseif platform.os == "linux" then
		return fs.path(os.getenv "XDG_DATA_HOME" or (os.getenv "HOME" .. "/.local/share")) / name
	elseif platform.os == "macos" then
		return fs.path(os.getenv "HOME" .. "/Library/Caches") / name
	else
		error "unknown os"
	end
end

local sandbox_path = (function ()
	if platform.os == "ios" then
		local ios = require "ios"
		return fs.path(ios.directory(ios.NSDocumentDirectory))
	elseif platform.os == "android" then
		local android = require "android"
		return fs.path(android.directory(android.ExternalDataPath))
	else
		return app_path "ant" / "sandbox"
	end
end)()

fs.create_directories(sandbox_path / "download")

local download_index = 1
if fs.exists(sandbox_path / "download" / "index") then
    local index = math.tointeger(readall(sandbox_path / "download" / "index"))
    if index then
        download_index = index
    end
end

local reskey <const> = (function ()
    local caps = bgfx.get_caps()
    local renderer = caps.rendererType:lower()
    return ("%s-%s"):format(platform.os, renderer)
end)()

download_patch(sandbox_path / "download", shortver, { reskey }, download_index)

local new_root
for i = download_index, 99 do
    local core_zip = sandbox_path / "download" / ("core/%02d.zip"):format(i)
    local res_zip = sandbox_path / "download" / ("%s/%02d.zip"):format(reskey, i)
    if not fs.exists(core_zip) then
        break
    end
    unzip(core_zip, sandbox_path / "vfs")
    if fs.exists(core_zip) then
        new_root = ("core/%02d.hash"):format(i)
    else
        unzip(res_zip, sandbox_path / "vfs")
        new_root = ("%s/%02d.hash"):format(reskey, i)
    end
end

if new_root then
    local root = readall(sandbox_path / "download" / new_root)
    writeall(sandbox_path / "vfs" / "root0", root)
end
