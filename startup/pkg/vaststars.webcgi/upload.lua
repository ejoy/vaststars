local ltask = require "ltask"
local crypt = require "crypt"

local function byte2hex(c)
	return ("%02x"):format(c:byte())
end

local function sha1(str)
	return crypt.sha1(str):gsub(".", byte2hex)
end

local M = {}

local function hash(path, name, content)
	local r = {
		"path : " .. path,
		"name : " .. name,
		"size : " .. #content,
		"sha1 : " .. sha1(content),
	}
	return table.concat(r, "\n")
end

local function boundary(header)
	local ctype = header["content-type"]
	if ctype == nil then
		return
	end
	local b = ctype:match "multipart/form%-data;%s*boundary=(.+)"
	return b
end

local pat = "--%s\r\n(.-)\r\n\r\n(.*)\r\n--%s"

local function extract_file(content, boundary)
	local header, data = content:match(pat:format(boundary, boundary))
	local filename = header:match 'Content%-Disposition:.-filename="(.-)"'
	return filename or "", data
end

local resp_header = {
	["Content-Type"] = "text/plain;charset=utf-8"
}

function M.post(path, q, header, content)
	local b = boundary(header)
	if b == nil then
		return 500, "Unsupported content-type : " .. (header["content-type"] or "")
	end
	local name, data = extract_file(content, b)
	return 200, hash(path, name, data), resp_header
end

return M
