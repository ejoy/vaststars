local fs = require "filesystem"


local M = {}

local html_header = [[
<html>
<head><meta charset="utf-8"></head>
<body>
<ul>
]]
local html_footer = [[
</ul>
</body>
]]

local content_text_types = {
    [".settings"] = true,
    -- ecs
    [".prefab"] = true,
    [".ecs"] = true,
    -- script
    [".lua"] = true,
    -- ui
    [".rcss"] = true,
    [".rml"] = true,
    -- animation
    [".event"] = true,
    [".anim"] = true,
    -- compiled resource
    [".cfg"] = true,
    [".attr"] = true,
    [".state"] = true,
}

local function get_file(path)
	local ext = path:extension():string():sub(2):lower()
	local localpath = path:localpath():string()
	local header = {
		["Content-Type"] = content_text_types[ext] and "text/html ; charset=UTF-8" or "application/octet-stream"
	}
	-- todo: use func for large file
	local f = assert(io.open(localpath, "rb"))
	local function reader()
		local bytes = f:read(4096)
		if bytes then
			return bytes
		else
			f:close()
		end
	end
	return reader, header
end

local function get_dir(path)
	local filelist = {}
	for file, file_status in fs.pairs(path) do
		local t = file_status:is_directory() and "d" or "f"
		table.insert(filelist, t .. file:filename():string())
	end
	table.sort(filelist)
	local list = { html_header }
	local pathname = path:string()
	if pathname ~= '/' then
		pathname = pathname .. "/"
	end
	for _, filename in ipairs(filelist) do
		local t , filename = filename:sub(1,1), filename:sub(2)
		local slash = t == "d" and "/" or ""
		table.insert(list, ('<li><a href="/vfs%s%s">%s%s</a></li>'):format(pathname, filename, filename, slash))
	end
	table.insert(list, html_footer)
	return table.concat(list, "\n")
end

local function get_path(path)
	if not fs.exists(path) then
		return
	end
	if fs.is_directory(path) then
		return get_dir(path)
	else
		return get_file(path)
	end
end

function M.get(path)
	if path == "" then
		path = "/"
	end
	local pathname = fs.path(path)
	local data = get_path(pathname)
	if data then
		return 200, data
	else
		return 403, "ERROR 403 : " ..  path .. " not found"
	end
end

return M