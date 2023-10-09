local webvfs = require "webvfs"

local M = {}

local webroot = "/web/"

function M.get(path)
	if path == "" or path == "/" then
		path = "index.html"
	end

	return webvfs.get(webroot .. path)
end

return M
