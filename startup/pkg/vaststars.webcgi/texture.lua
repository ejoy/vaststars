local ltask = require "ltask"

local M = {}

local ServiceMgr = ltask.queryservice "ant.resource_manager|resource"

local html_header = [[
<html>
<head><meta charset="utf-8"></head>
<body>
<table>
]]
local html_footer = [[
</table>
</body>
]]

local KEYS = { "id", "info", "name", "type", "handle" }

local function default_info(v)
	return v
end

local INFO = {}

function INFO.id(v)
	return ('<a href="texture/%d">%d</a>'):format(v,v)
end

local ignore_info = {
	storageSize = true,
	width = true,
	height = true,
	numLayers = true,
	depth = true,
	cubeMap = true,
	numMips = true,
	format = true,
	bitsPerPixel = true,
}

function INFO.info(v)
	local info = {}
	local size = v.storageSize
	if size > 65536 then
		table.insert(info, ('<div style="color:red">%s</div>'):format(size))
	else
		table.insert(info, tostring(size))
	end
	table.insert(info, ("%dx%dx%d"):format(v.width, v.height, v.bitsPerPixel))
	if v.numLayers ~= 1 then
		table.insert(info, "layer:".. v.numLayers)
	end
	if v.depth ~= 1 then
		table.insert(info, "depth:" .. v.depth)
	end
	if v.cubeMap then
		table.insert(info, "cubemap")
	end
	if v.numMips ~= 1 then
		table.insert(info, "mips:" .. v.numMips)
	end
	table.insert(info, v.format)
	for k,v in pairs(v) do
		if not ignore_info[k] then
			table.insert(info, k .. ":" .. tostring(v))
		end
	end
	return table.concat(info, ",")
end

function INFO.handle(v)
	return tostring(v ~= nil)
end

local function format_texture(html, t)
	table.insert(html, "<tr>")
	for _, key in ipairs(KEYS) do
		local f = INFO[key] or default_info
		table.insert(html, "<td>")
		local v = t[key]
		table.insert(html, v and f(v) or "")
		table.insert(html, "</td>")
	end
	table.insert(html, "</tr>")
end

local function get_list()
	local html = { html_header }
	local tl = ltask.call(ServiceMgr, "texture_list")
	for _, item in ipairs(tl) do
		format_texture(html, item)
	end
	table.insert(html, html_footer)
	return table.concat(html, "\n")
end

local png_header = {
	["Content-Type"] = "image/png",
}

local function get_png(id)
	local png = ltask.call(ServiceMgr, "texture_png", id)
	if png then
		return 200, png, png_header
	else
		return 403, "No texture " .. id
	end
end

function M.get(path, q)
	if path == "" then
		return 200, get_list()
	else
		local id = tonumber(path)
		if id then
			return get_png(id)
		else
			return 403, "Unknown " .. path
		end
	end
end

return M
