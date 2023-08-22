package.path = "engine/?.lua"
require "bootstrap"
local task = dofile "/engine/task/bootstrap.lua"
task {
    bootstrap = { "vaststars.tools|tools_root" },
    logger = { "logger" },
    exclusive = { "timer", "subprocess" },
    debuglog = "debug.txt",
}
