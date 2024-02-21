package.path = "/engine/?.lua"
require "bootstrap"

local options = {}

for i, a in ipairs(arg) do
	if a == "-f" then
		local size = "1280x720"
		if arg[i+1] and arg[i+1]:sub(1,1) ~= "-" then
			size = arg[i+1]
		end
		options.window_size = size
	end
end

import_package "ant.window".start {
	window_size = options.window_size,
	feature = {
		"vaststars.gamerender|login",
	}
}
