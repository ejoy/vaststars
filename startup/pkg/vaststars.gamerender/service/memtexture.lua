local ltask 		= require "ltask"
local bgfx  		= require "bgfx"
local ServiceWorld  = ltask.queryservice "ant.window|world"
local S 			= {}

local DEFAULT_SIZE_CONFIGS <const> = {
	{
		width  = 512,
		height = 512,
	},
	{
		width  = 256,
		height = 256,
	},
	{
		width  = 128,
		height = 128,
	},	
}

local DEFAULT_STATIC_ROT_CONFIGS <const> = {
	{0.785, 0, 0},
	{0.785, -0.785, 0},
	{0.785, 0.785, 0},
}

local DEFAULT_DYNAMIC_ROT_CONFIG = {0.785, 0, 0}

local RT_CACHE = {}

local function init()
	local textmgr = ltask.uniqueservice "ant.resource_manager|resource"
	ltask.call(textmgr, "register", "mem", ltask.self())
end

function S.load(path, config)

	local function parse_config()
		return config:match "%w+:(%a),(%d),(%d),?([%d%.]*)"
	end

	local type, size_config, rot_config, dis_config = parse_config()
	local is_dynamic = type == 'd'
	local size 		 = size_config and DEFAULT_SIZE_CONFIGS[tonumber(size_config)] or DEFAULT_SIZE_CONFIGS[1]
	local rot  	     = rot_config  and DEFAULT_STATIC_ROT_CONFIGS[tonumber(rot_config)] or DEFAULT_STATIC_ROT_CONFIGS[1]
	local dis 		 = dis_config and tonumber(dis_config) or 1.0
	local c 		 = {
		info = {
            width = size.width,
            height = size.height,
            format = "RGBA8",
            mipmap = false,
            depth = 1,
            numLayers = 1,
            cubeMap = false,
            storageSize = 4,
            numMips = 1,
            bitsPerPixel = 32,
		},
		flag = "+l-lvcucrt",
		handle = nil,
	}

	if is_dynamic then
		local rt_idx
		c.handle, rt_idx = ltask.call(ServiceWorld, "create_mem_texture_dynamic_prefab", path, size.width, size.height, DEFAULT_DYNAMIC_ROT_CONFIG, dis)
		RT_CACHE[c.handle] = rt_idx
	else
		c.handle = ltask.call(ServiceWorld, "create_mem_texture_static_prefab", path, size.width, size.height, rot, dis)
	end

	return c, is_dynamic
end

function S.unload(handle)
	bgfx.destroy(handle)
	ltask.call(ServiceWorld, "destroy_mem_texture_dynamic_prefab", RT_CACHE[handle])
end

init()

return S
