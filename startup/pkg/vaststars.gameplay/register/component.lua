local status = require "status"

local function ExtraSyntax(components, c)
	local r = {}
	for _, field in ipairs(c) do
		local name, typename, n = field:match "^([%w_]+):([^%]]+)%[(%d+)%]$"
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
			name, typename = field:match "^([%w_]+):(.+)$"
			if components[typename] then
				r[#r+1] = ("%s:%s"):format(name, components[typename])
			else
				r[#r+1] = field
			end
		end
	end
	return r
end

local def = {}

function def.component(name)
	return function (object)
		local components = status.components
		object = ExtraSyntax(components, object)
		object.name = name
		components[name] = object
		components[#components+1] = object
	end
end

function def.type(name)
	return function (object)
		local components = status.components
		components[name] = object
	end
end

return def
