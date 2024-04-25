local ecs = ...
local world = ecs.world
local w = world.w

local ltask = require "ltask"

-- todo: more info
local function register_command()
	local S = ltask.dispatch()

    local COMMAND = {}
    COMMAND.ping = function(q)
        return {COMMAND = q}
    end
	COMMAND.traceback = function(cmd, q)
		local timeout = tonumber(q.timeout or 100)
		local tlog = ltask.call(1, "tracelog", timeout)
		return tlog
	end

	function S.world_command(what, ...)
		print("world_command|pub message", what, ...)
        world:pub {"web_cgi_cmd", what, ...}
        return "SUCCESS"
    end

    function S.command(what, ...)
        local c = assert(COMMAND[what])
		return c(what, ...)
	end
end

return function ()
	register_command()
end