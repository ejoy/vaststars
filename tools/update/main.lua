package.path = "/engine/?.lua"
require "bootstrap"

dofile "/engine/ltask.lua" {
    bootstrap = {
        ["logger"] = {},
        ["vaststars.update|boot"] = { unique = false }
    }
}
