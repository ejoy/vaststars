package.path = "/engine/?.lua"
require "bootstrap"

import_package "ant.window".start {
    -- todo: read user config
    -- window_size = "1280x720",
    feature = {
        "vaststars.gamerender|login",
    }
}
