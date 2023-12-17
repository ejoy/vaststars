local fastio = require "fastio"
local datalist = require "datalist"
local lfs = require "bee.filesystem"
local vfs = require "vfs"
local serialize = import_package "ant.serialize"

vfs.call("RESOURCE_SETTING", "windows-direct3d11")
local function readall(path)
    local memory = vfs.read(path) or error(("`read `%s` failed."):format(path))
    return fastio.wrap(memory)
end

local function localreadall(path)
	local file <close> = assert(io.open(path, "rb"))
	return file:read "a"
end

local function localwriteall(file, content)
    local f <close> = assert(io.open(file, "wb"))
    f:write(content)
end

local BASE_LOCALPATH <const> = lfs.path(vfs.repopath() .. "../startup/pkg/vaststars.resources/glbs/"):lexically_normal()
local function dir(p)
	local t = {}
	for v in lfs.pairs(p) do
		if lfs.is_directory(v) then
			goto continue
		end
		if not v:equal_extension ".glb" then
			goto continue
		end
		t[#t+1] = v
	    ::continue::
	end
	return t
end

local function has_animation(t)
	for _, v in ipairs(t) do
		if v.data and v.data.animation then
			return true
		end
	end
end

local function patch_has_anim_ctrl(patch)
	for _, v in ipairs(patch) do
		if v.file ~= "mesh.prefab" then
			goto continue
		end
		if v.op ~= "replace" then
			goto continue
		end
		if #v.value ~= 1 then
			goto continue
		end
		if v.value[1] ~= "anim_ctrl" then
			goto continue
		end
		do
			return true
		end
	    ::continue::
	end
end

local function get_pkg_path(p)
	local relative = lfs.relative(p, BASE_LOCALPATH)
	return "/pkg/vaststars.resources/glbs/" .. relative:string()
end

for _, localpath in ipairs(dir(BASE_LOCALPATH)) do
	local path = get_pkg_path(localpath:string())
	local patch_localpath = (localpath .. ".patch"):string()

	local mesh_prefab = datalist.parse(readall(path .. "|mesh.prefab"))
	local patch = datalist.parse(localreadall(patch_localpath))
	if has_animation(mesh_prefab) and not patch_has_anim_ctrl(patch) then
		print(localpath:string())
		table.insert(patch, 1, {
			file = "mesh.prefab",
			op = "replace",
			path = "/2/tag",
			value = {"anim_ctrl"},
		})
		localwriteall(patch_localpath, serialize.stringify(patch))
	end
end

print "ok"