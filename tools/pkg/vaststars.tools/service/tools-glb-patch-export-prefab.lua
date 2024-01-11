-- 导出 prefab

dofile "/engine/bootstrap.lua"

local fs = require "bee.filesystem"
local cr = import_package "ant.compile_resource"
local serialize = import_package "ant.serialize"

local function init_setting()
	local function sortpairs(t)
		local sort = {}
		for k in pairs(t) do
			sort[#sort+1] = k
		end
		table.sort(sort)
		local n = 1
		return function ()
			local k = sort[n]
			if k == nil then
				return
			end
			n = n + 1
			return k, t[k]
		end
	end
	local function stringify(t)
		local s = {}
		for k, v in sortpairs(t) do
			s[#s+1] = k.."="..tostring(v)
		end
		return table.concat(s, "&")
	end
	local OS <const> = "windows"
	local Renderer <const> = "direct3d11"
	local HomogeneousDepth <const> = true
	local OriginBottomLeft <const> = true
	local TextureExtensions <const> = {
		noop        = OS == "windows" and "dds" or "ktx",
		direct3d11 	= "dds",
		direct3d12  = "dds",
		metal       = "ktx",
		vulkan      = "ktx",
		opengl      = "ktx",
	}
	local BgfxOS <const> = {
		macos = "osx",
	}
	cr.init_setting()
	cr.set_setting("glb", stringify {
		os = OS,
		renderer = Renderer,
		hd = HomogeneousDepth,
		bl = OriginBottomLeft,
	})
	cr.set_setting("material", stringify {
		os = OS,
		renderer = Renderer,
		hd = HomogeneousDepth,
		obl = OriginBottomLeft,
	})
	cr.set_setting("texture", stringify {
		os = OS,
		ext = TextureExtensions[Renderer],
	})
end
init_setting()

local BASEDIR <const> = (fs.current_path() / "../../"):lexically_normal()
local GLB_BASE_PATH <const> = BASEDIR .. "startup/pkg/mod.crack/assets/shapes"
local GLB_PATH <const> = GLB_BASE_PATH / ""
local PREFAB_PATH <const> = (GLB_BASE_PATH / ""):lexically_normal()
local GLB_FS_PATH <const> = "/pkg/mod.crack/assets/shapes"

local function dir(p)
	local t = {}
	for v in fs.pairs(p) do
		if not fs.is_directory(v) and v:equal_extension ".glb" then
			t[#t+1] = v
		end
	end
	return t
end

local function readall(resource, relative)
    assert(resource:string())
    print(resource:string())
    local res = cr.compile_file(resource:string())
    assert(res)
	local f = io.open(res .. relative, "rb")
    assert(f, res .. relative)
    local r = f:read "a"
    f:close()
    return r
end

local function writeall(file, content)
    local f <close> = assert(io.open(file, "wb"))
    f:write(content)
end

for _, f in ipairs(dir(GLB_PATH)) do
	print(f:string())
    local related = fs.relative(f, GLB_BASE_PATH)
	local prefabData = serialize.parse((GLB_FS_PATH / related .. "|"):string(), readall(f, "/mesh.prefab"))
    local prefabFile = PREFAB_PATH / related:replace_extension(".prefab")
    writeall(prefabFile:string(), serialize.stringify(prefabData))
end

print "ok"