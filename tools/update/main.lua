package.path = "/engine/?.lua"
require "bootstrap"

dofile "/engine/ltask.lua" {
    bootstrap = { "vaststars.update|boot" },
    exclusive = { "timer" },
}
