return function(arg)
	local options = {
		boot = "vaststars.gameplay|boot",
		web_port = 9000,
	}

	local i = 1
	while true do
		local a = arg[i]; i = i + 1
		if a == nil then
			break
		end
		if a == "-f" then
			local size = "1280x720"
			if arg[i] and arg[i]:sub(1,1) ~= "-" then
				size = arg[i]
			end
			options.window_size = size
			i = i + 1
		elseif a == "-port" then
			options.web_port = assert(tonumber(arg[i]))
			i = i + 1
		end
	end

	return options
end