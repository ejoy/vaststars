local status = require "base.status"

local unit = status.unit
local types = status.types
local ctor = status.ctor

local function ctor_function(typename, func)
	assert(type(func) == "function")
	local t = types[typename]
	if t == nil then
		error ("Unknown type : " .. typename)
	end
	ctor[typename] = func
end

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
		assert(what == "ctor")
		ctor_function(name, f)
	end
	return inserter
end
