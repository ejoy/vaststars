local ltask = require "ltask"

print "Webserver start"

local ServiceIO = ltask.queryservice "io"
local WEB_PORT <const> = "9000"

if __ANT_RUNTIME__ then
	local function main()
		ltask.send(ServiceIO, "REDIRECT", "TUNNEL", ltask.self())
		ltask.send(ServiceIO, "SEND", "TUNNEL_OPEN", WEB_PORT)
	end

	main()
end

local S = {}

local function response(session, resp)
	ltask.send(ServiceIO, "SEND", "TUNNEL_RESP", WEB_PORT, tostring(session), resp)
end

function S.TUNNEL(port, session, req)
	-- todo : pingpong server now, add web server
	response(session, req)
end

return S
