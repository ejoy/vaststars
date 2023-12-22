package.path = "/engine/?.lua"
require "bootstrap"

import_package "ant.window".start {
    window_size = "1280x720",	-- todo: read user config
    feature = {
        "vaststars.gamerender|login",
    }
}
