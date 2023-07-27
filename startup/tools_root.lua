dofile "/engine/bootstrap.lua"

local fs = require "bee.filesystem"
local basedir = (fs.current_path() / "../../"):lexically_normal()
local path = basedir .. "startup/pkg/vaststars.resources/prefabs/stackeditems/"
local assetmgr = import_package "ant.asset"
assetmgr.init()

local function dir(p)
	local t = {}
	for v in fs.pairs(fs.path(p)) do
		if fs.is_directory(v) then
			local tmp = dir(v)
			table.move(tmp, 1, #tmp, #t + 1, t)
		else
			t[#t+1] = v:string():match(("^.*(/pkg/.*)$"))
		end
	end
	return t
end

local function readall(file)
	local f <close> = assert(fs.open(assetmgr.compile(file), "rb"))
    return f:read "a"
end

for _, f in ipairs(dir(path)) do
	local a = readall(f:match("^(.*)%.prefab$") .. ".glb|mesh.prefab")
	local i = 0
end

print "ok"