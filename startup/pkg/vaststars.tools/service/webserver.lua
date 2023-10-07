local ltask = require "ltask"
local httpd = require "http.httpd"
local urllib = require "http.url"

print "Webserver start"

local ServiceIO = ltask.queryservice "io"
local WEB_PORT <const> = "9000"
local WEB_TUNNEL <const> = "WEBTUN"

if __ANT_RUNTIME__ then
	local function main()
		ltask.send(ServiceIO, "REDIRECT", WEB_TUNNEL, ltask.self())
		ltask.send(ServiceIO, "SEND", "TUNNEL_OPEN", WEB_PORT, WEB_TUNNEL)
	end

	main()
end

local socket_error = setmetatable({} , { __tostring = function() return "[Socket Error]" end })

local iofuncs ; do
	iofuncs = function (session)
		session = tostring(session)
		local io = {}
		local msg = {}
		local waiting

		function io.append(str)
			msg[#msg+1] = str
			if waiting then
				ltask.wakeup(waiting)
				waiting = nil
			end
		end

		function io.read(size)
			if msg[1] == nil then
				waiting = coroutine.running()
				ltask.wait(waiting)
				if msg[1] == nil then
					error(socket_error)
				end
			end
			if size == nil then
				return table.remove(msg, 1)
			else
				local r = msg[1]
				while true do
					local len = #r
					if len > size then
						msg[1] = r:sub(size+1)
						return r:sub(1, size)
					end
					table.remove(msg, 1)
					if len == size then
						return r
					end
					if msg[1] == nil then
						waiting = coroutine.running()
						ltask.wait(waiting)
						if msg[1] == nil then
							error(socket_error)
						end
					end
					r = r .. msg[1]
				end
			end
		end

		function io.write(str)
			ltask.send(ServiceIO, "SEND", "TUNNEL_RESP", WEB_PORT, session, str)
		end

		function io.close()
			ltask.send(ServiceIO, "SEND", "TUNNEL_RESP", WEB_PORT, session)
		end

		return io
	end
end

local sessions = {}

local function response(session, write, ...)
	local ok, err = httpd.write_response(write, ...)
	if not ok then
		if err ~= socket_error then
			print(string.format("session = %d, %s", session, err))
		end
	end
end

local function http_request(s)
	local code, url, method, header, body = httpd.read_request(s.read)
	if code then
		if code ~= 200 then
			response(id, s.write, code)
		else
			local tmp = {}
			if header.host then
				table.insert(tmp, string.format("host: %s", header.host))
			end
			local path, query = urllib.parse(url)
			table.insert(tmp, string.format("path: %s", path))
			if query then
				local q = urllib.parse_query(query)
				for k, v in pairs(q) do
					table.insert(tmp, string.format("query: %s= %s", k,v))
				end
			end
			table.insert(tmp, "-----header----")
			for k,v in pairs(header) do
				table.insert(tmp, string.format("%s = %s",k,v))
			end
			table.insert(tmp, "-----body----\n" .. body)
			response(id, s.write, code, table.concat(tmp,"\n"))
		end
	else
		if url == socket_error then
			print "socket closed"
		else
			print(url)
		end
	end

	s.close()

	sessions[s] = nil
end

local S = {}

setmetatable(sessions , {
	__index = function(o, session)
		local s = iofuncs(session)
		o[session] = s
		ltask.fork(http_request,s)
		return s
	end
})

S[WEB_TUNNEL] = function (port, session, req)
	local s = sessions[session]
	s.append(req)
end

return S
