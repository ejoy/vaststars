local ecs = ...
local world = ecs.world
local w = world.w

local ltask = require "ltask"

-- todo: more info
local function register_debug()
	local S = ltask.dispatch()

    local COMMAND = {}
    COMMAND.ping = function(q)
        return {COMMAND = q}
    end

	function S.send(what, ...)
        world:pub {"game_debug", what, ...}
        return "SUCCESS"
    end

    function S.call(what, ...)
        local c = assert(COMMAND[what])
		return c(what, ...)
	end
end

return function ()
	local webserver = import_package "vaststars.webcgi"

	if __ANT_RUNTIME__ then
		register_debug()
		webserver.start "redirect"
	else
		webserver.start "direct"
	end
end