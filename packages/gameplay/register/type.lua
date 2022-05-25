local status = require "status"

local unit = status.unit
local types = status.types
local typefuncs = status.typefuncs

return function (name)
	assert(types[name] == nil)
	local typeobject = { name = name }
	types[name] = typeobject
	local keys = {}
	types[name] = typeobject
	local meta = {}
	local inserter = setmetatable({}, meta)
	function meta:__index(keyname)
		assert(keys[keyname] == nil)
		keys[keyname] = true
		return function( unitname )
			assert(unit[unitname], unitname)
			table.insert(typeobject, { key = keyname, unit = unitname } )
			return inserter
		end
	end
	function meta:__newindex(what, f)
		assert(type(f) == "function")
		local funcs = typefuncs[name]
		if not funcs then
			funcs = {}
			typefuncs[name] = funcs
		end
		funcs[what] = f
	end
	return inserter
end
