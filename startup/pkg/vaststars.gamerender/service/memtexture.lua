local ltask 		= require "ltask"
local ServiceWorld  = ltask.queryservice "ant.window|world"
local S 			= {}

local function init()
	local textmgr = ltask.uniqueservice "ant.resource_manager|resource"
	ltask.call(textmgr, "register", "mem", ltask.self())
end

function S.load(name, path, config)
	local type, size, rot, dis = ltask.call(ServiceWorld, "parse_prefab_config", config)

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

	c.handle = ltask.call(ServiceWorld, "get_portrait_handle", name, size.width, size.height)
	ltask.call(ServiceWorld, "set_portrait_prefab", name, path, rot, dis, type)
	return c, true
end

function S.unload(handle)
	ltask.call(ServiceWorld, "destroy_portrait_handle", handle)
end

init()

return S
