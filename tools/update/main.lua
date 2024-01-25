package.path = "/engine/?.lua"
require "bootstrap"

local function start_ltask()
    local task = dofile "/engine/task/bootstrap.lua"
    local exclusive = { "timer", "subprocess" }
	local directory = require "directory"
	local log_path = directory.app_path()
    task {
        bootstrap = { "vaststars.update|boot" },
        logger = { "logger" },
        exclusive = exclusive,
        debuglog = (log_path / "debug.log"):string(),
        crashlog = (log_path / "crash.log"):string(),
        worker = 4,
    }
end

start_ltask()
