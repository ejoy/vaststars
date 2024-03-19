package.path = "/engine/?.lua"
require "bootstrap"

local cmdline = import_package "vaststars.cmd"
local options
if __ANT_RUNTIME__ then
	options = cmdline(arg)
else
	options = cmdline(...)
end

options.feature = {
	"vaststars.gamerender|login",
}

import_package "ant.window".start(options)
