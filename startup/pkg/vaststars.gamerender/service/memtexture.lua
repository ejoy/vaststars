local ltask 		= require "ltask"
local ServiceWindow  = ltask.queryservice "ant.window|window"
local S 			= {}

local function init()
	local textmgr = ltask.uniqueservice "ant.resource_manager|resource"
	ltask.call(textmgr, "register", "mem", ltask.self())
end

function S.load(name, path, config)
	local type, size, rot, dis = ltask.call(ServiceWindow, "parse_prefab_config", config)

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

	c.handle = ltask.call(ServiceWindow, "get_portrait_handle", name, size.width, size.height)
	ltask.call(ServiceWindow, "set_portrait_prefab", name, path, rot, dis, type)
	return c, true
end

function S.unload(handle)
	ltask.call(ServiceWindow, "destroy_portrait_handle", handle)
end

init()

return S
