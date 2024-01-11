-- 生成堆叠的 glb.patch
-- 生成规则 
--[[
统一替换材质
---
file: materials/Material.001.material
op: add
path: /fx/vs_code
value: '#include \"rotator/rotator_vs_func.sh\"'
---
file: materials/Material.001.material
op: add
path: /fx/setting/no_predepth
value: true
---
file: materials/Material.001.material
op: add
path: /properties/u_rotator_rate
value: {1, 0, 0, 0}
--]]

dofile "/engine/bootstrap.lua"

local fs = require "bee.filesystem"
local cr = import_package "ant.compile_resource"
local serialize = import_package "ant.serialize"
local datalist  = require "datalist"

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
local GLB_PATH <const> = BASEDIR .. "startup/pkg/vaststars.resources/glbs/stackeditems"
local GLB_BASE_PATH <const> = BASEDIR .. "startup/pkg/vaststars.resources/glbs"
local GLB_VS_BASE_PATH <const> = "/pkg/vaststars.resources/glbs"

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

local function getRealPath(Mapping, materialRelated)
    local key = fs.path(materialRelated):filename():replace_extension(""):string()
    local Realname = Mapping[key]
    assert(Realname, "not found material: " .. materialRelated)
    return fs.path(materialRelated):replace_filename(Realname):string() .. fs.path(materialRelated):extension():string()
end

local function length(t)
    local n = 0
    for _ in pairs(t) do
        n = n + 1
    end
    return n
end

for _, f in ipairs(dir(GLB_PATH)) do
	print(f:string())
    local related = fs.relative(f, GLB_BASE_PATH)
	local prefabData = serialize.parse((GLB_VS_BASE_PATH / related .. "|"):string(), readall(f, "/mesh.prefab"))
    local materialMapping = datalist.parse(readall(f, "/materials.names"))
    local foundMaterialIdx

    for i, v in ipairs(prefabData) do
        if v.data.material then
            assert(foundMaterialIdx == nil)
            foundMaterialIdx = i
            break
        end
    end
    assert(foundMaterialIdx, "not found material" .. f:string())

    local materialRelated = prefabData[foundMaterialIdx].data.material:match("^.*%|(.*)$")
    local materialData = serialize.parse((GLB_VS_BASE_PATH / related .. "|"):string(), readall(f, "/" .. materialRelated .. "/source.ant"))
    local materialReal = getRealPath(materialMapping, materialRelated)
    local patchNodes = {}

    patchNodes[#patchNodes+1] = {
        file = materialReal,
        op = "replace",
        path = "/fx/vs_code",
        value = "#include \"rotator/rotator_vs_func.sh\"",
    }

    patchNodes[#patchNodes+1] = {
        file = materialReal,
        op = "replace",
        path = "/fx/setting/no_predepth",
        value = true,
    }

    patchNodes[#patchNodes+1] = {
        file = materialReal,
        op = "replace",
        path = "/properties/u_rotator_rate",
        value = {1, 0, 0, 0},
    }

    -- local glbPatch = f:replace_extension(""):replace_extension(".glb.patch"):string()
    -- writeall(glbPatch, serialize.stringify(patchNodes))
end

print "ok"

