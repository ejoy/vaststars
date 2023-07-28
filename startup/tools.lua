package.path = "engine/?.lua"
require "bootstrap"
local task = dofile "/engine/task/bootstrap.lua"
task {
    support_package = true,
    service_path = "/engine/service/?.lua;${package}/service/?.lua;../../startup/?.lua;",
	lua_path = "/engine/?.lua;",
    bootstrap = { "tools_root" },
    logger = { "logger" },
    exclusive = { "timer", "subprocess" },
    debuglog = "debug.txt",
}
