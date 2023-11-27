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

local DEFAULT_ROT_CONFIGS <const> = {
	{0, 0, 0},
	{0, -0.5, 0},
	{0, 0.5, 0},
}

local function init()
	local textmgr = ltask.uniqueservice "ant.resource_manager|resource"
	ltask.call(textmgr, "register", "mem", ltask.self())
end

function S.load(path, config)

	local function parse_config()
		return config:match "%w+:(%d),(%d)"
	end

	local size_config, rot_config = parse_config()
	local size = size_config and DEFAULT_SIZE_CONFIGS[tonumber(size_config)] or DEFAULT_SIZE_CONFIGS[1]
	local rot  = rot_config  and DEFAULT_ROT_CONFIGS[tonumber(rot_config)]   or DEFAULT_ROT_CONFIGS[1]
	local c = {
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

	c.handle = ltask.call(ServiceWorld, "create_mem_texture_prefab", path, size.width, size.height, rot)

	return c
end

init()

return S
