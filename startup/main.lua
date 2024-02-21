package.path = "/engine/?.lua"
require "bootstrap"

local options = {}

if arg[1] == "-f" then
	options.window_size = "1280x720"
end

import_package "ant.window".start {
    window_size = options.window_size,
    feature = {
        "vaststars.gamerender|login",
    }
}
