local ltask = require "ltask"

local function start(mode)
	local web = ltask.uniqueservice "ant.webserver|webserver"
	ltask.call(web, "start", {
		mode = mode,
		port = 9000,
		cgi = {
			debug = "vaststars.webcgi|debug",
			upload = "vaststars.webcgi|upload",
			texture = "vaststars.webcgi|texture",
			repo = "vaststars.webcgi|repo",
		},
		route = {
			vfs = "vfs:/",
			log = "log:/",
			app = "app:/",
		},
		home = "vfs:/web",
	})
end

return {
	debug = require "debugger",
	upload = require "upload",
	texture = require "texture",
	repo = require "repo",
	start = start,
}
