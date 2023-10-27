local lfs = require "bee.filesystem"
local directory = require "directory"
local REPO_PATH = directory.app_path():string() .. "/.repo/"

local M = {}

local hash_index = [[
<html>
<head>
  <meta charset="UTF-8">
  <title>Repository</title>
</head>
<body>
<pre>
{ROOT}
</pre>
<p>{TOTAL} files</p>
<p><ul>
%s
</ul></p>
</body>
]]

function init_index()
	local tmp = {}
	for i = 0, 0xff do
		table.insert(tmp, ('<li><a href="/app/.repo/%02x">%02x</a> {%02x} files </li>\n'):format(i,i,i))
	end
	local content = table.concat(tmp)
	hash_index = hash_index:format(content)
end

init_index()

local function count_files(path)
	local n = 0
	for path in lfs.pairs(path) do
		if not path:string():find "%.resource$" then
			n = n + 1
		end
	end
	return n
end

local function invalid_path(path)
	if #path < 3 then
		return true
	end
	path = path:lower()
	if path:find "[^%da-f]" then
		return true
	end
end

local plaintext = {	["Content-Type"] = "text/plain;charset=utf-8" }
local htmltext = { ["Content-Type"] = "text/html" }
local blob = { ["Content-Type"] = "application/octet-stream" }

local content_temp_header = [[
<html>
<head><meta charset="utf-8"></head>
<body>
<pre>
]]

local content_temp_footer = [[

</pre>
</body>
]]

local SHA1 = ("[0-9a-f]"):rep(40)

local function link_sha1(s)
	return ('<a href="/repo/%s">%s</a>'):format(s,s)
end

local function add_links(content)
	local n = content:find(SHA1)
	if n then
		return content_temp_header .. content:gsub(SHA1, link_sha1) .. content_temp_footer, htmltext
	else
		return content, plaintext
	end
end

local function list_prefix(files)
	return add_links(table.concat(files, "\n"))
end

local function view_file(fullpath)
	local f = assert(io.open(fullpath, "rb"))
	local c = f:read "a"
	f:close()
	if c:find "\0" then
		-- binary files
		return c, blob
	elseif c:find "[<>]" then
		return c, plaintext
	else
		return add_links(c)
	end
end

local function get_hash_prefix(prefix, header)
	local head = prefix:sub(1,2)
	local path = REPO_PATH .. head
	local files = {}
	local n = #prefix
	for file in lfs.pairs(path) do
		local name = file:filename():string()
		if name:sub(1,n) == prefix then
			if not name:find "%.resource$" then
				table.insert(files, name)
			end
		end
	end
	local count = #files
	if count == 0 then
		return 404, "Not found : " .. prefix
	elseif count == 1 then
		local t = {}
		for k,v in pairs(header) do
			table.insert(t, k .. ":" .. v .. "\n")
		end
		local fullname = files[1]
		if fullname ~= prefix then
			return 302, "Found", { Location = "/repo/" .. fullname }
		else
			return 200, view_file(path .. "/" .. fullname)
		end
	else
		return 200, list_prefix(files)
	end
end

local function link_sha1_resource(s)
	return ('<a href="/repo/%s">%s</a> (<a href="/repo/resource/%s">RESOURCE</a>)'):format(s,s,s)
end

local function get_root()
	local f = io.open(REPO_PATH .. "root", "rb")
	if not f then
		return "No ROOT"
	end
	local content = f:read "a"
	f:close()
	return content:gsub(SHA1, link_sha1_resource)
end

local function get_hash_index()
	local total = 0
	local count = {}
	for i = 0, 0xff do
		local name = string.format("%02x", i)
		local path = REPO_PATH .. name
		local n = count_files(path)
		total = total + n
		count[name] = n
	end
	count.TOTAL = total
	count.ROOT = get_root()
	return (hash_index:gsub ("{(.-)}", count))
end

local function get_resource(hash)
	local head = hash:sub(1,2)
	local path = REPO_PATH .. "/" .. head .. "/" .. hash .. ".resource"
	local f = io.open(path, "rb")
	if not f then
		return 404, "Not Found RESOURCE " .. hash
	end
	local content = f:read "a"
	f:close()
	return 200, add_links(content)
end

function M.get(path, q , header)
	if path == "" then
		return 200, get_hash_index()
	else
		local resource = path:match "^resource/(.*)"
		if resource then
			return get_resource(resource)
		elseif invalid_path(path) then
			return 404, "Invalid " ..  tostring(path)
		else
			return get_hash_prefix(path, header)
		end
	end
end

return M
