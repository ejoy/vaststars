package.path = "/engine/?.lua"
require "bootstrap"

local cmdline = import_package "vaststars.cmd"
local options = cmdline(...)

options.feature = {
	"vaststars.gamerender|login",
}

import_package "ant.window".start(options)
