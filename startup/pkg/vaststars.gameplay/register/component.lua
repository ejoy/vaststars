local status = require "status"

local function ExtraSyntax(components, c)
	local r = {}
	for _, field in ipairs(c) do
		local name, typename, n = field:match "^([%w_]+):(%w+)%[(%d+)%]$"
		if name then
			local usertype = components[typename]
			if usertype then
				for i = 1, tonumber(n) do
					for _, userfield in ipairs(usertype) do
						local uname, utypename = userfield:match "^([%w_]+):(%w+)$"
						r[#r+1] = ("%s%d_%s:%s"):format(name, i, uname, utypename)
					end
				end
			else
				for i = 1, tonumber(n) do
					r[#r+1] = ("%s%d:%s"):format(name, i, typename)
				end
			end
		else
			local usertype = components[typename]
			if usertype then
				for _, userfield in ipairs(usertype) do
					local uname, utypename = userfield:match "^([%w_]+):(%w+)$"
					r[#r+1] = ("%s_%s:%s"):format(name, uname, utypename)
				end
			else
				r[#r+1] = field
			end
		end
	end
	return r
end

return function (name)
	return function (object)
		local components = status.components
		object = ExtraSyntax(components, object)
		object.name = name
		components[name] = object
		components[#components+1] = object
	end
end
