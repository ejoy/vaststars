local ltask = require "ltask"
local bgfx = require "bgfx"

local S = {}

local function init()
	local textmgr = ltask.uniqueservice "ant.resource_manager|resource"
	ltask.call(textmgr, "register", "mem", ltask.self())
end

function S.load(path)
	-- todo:
	local c = {
		info = {
            width = 1,
            height = 1,
            format = "RGBA8",
            mipmap = false,
            depth = 1,
            numLayers = 1,
            cubeMap = false,
            storageSize = 4,
            numMips = 1,
            bitsPerPixel = 32,
		},
		flag = "umwwvm+l*p-l",
		handle = nil,
	}
	c.handle = bgfx.create_texture2d(1, 1, false, 1, "RGBA8", c.flag,
		bgfx.memory_buffer("bbbb", {0xff,0,0,0}))
	return c
end

init()

return S
