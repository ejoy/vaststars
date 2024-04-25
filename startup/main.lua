local cmdline = import_package "vaststars.cmd"
local options = cmdline(...)
local settings_manager = import_package "vaststars.settings_manager"

options.feature = {
	"vaststars.gamerender|login",
}

if options.boot then
	local ltask = require "ltask"
	ltask.spawn(options.boot, options)
end

local window_size = settings_manager.get("window_size")
if window_size then
	options.window_size = window_size
end

import_package "ant.window".start(options)
