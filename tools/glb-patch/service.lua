local service = ...
package.path = "/engine/?.lua"
require "bootstrap"
local task = dofile "/engine/task/bootstrap.lua"
task {
    bootstrap = { ("vaststars.tools|%s"):format(service) },
    logger = { "logger" },
    exclusive = { "timer", "subprocess" },
    debuglog = "debug.txt",
}
