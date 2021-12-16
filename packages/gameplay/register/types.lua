local status = require "status"
local prototype = require "prototype"

local unit = status.unit

local UPS <const> = 50

local function register_unit(name, type, converter)
	assert(unit[name] == nil)
	unit[name] = {
		name = name,
		type = type,
		converter = converter,
	}
end

local function number_conversion(n, u)
	n = n + 0
	if u == 'k' then
		n = n * 1000
	elseif u == 'M' then
		n = n * 1000000
	elseif u == 'G' then
		n = n * 1000000000
	elseif u ~= '' then
		error ("Invalid postfix " .. u)
	end
	return n
end

register_unit("power", "float", function(s)
	local n, u = s:match "^(%d+%.?%d*)([kMG]?)W$"
	assert(n, "Need power : nW")
	return number_conversion(n,u) / UPS
end)

register_unit("drain_power", "float", function(s, object)
	if s == nil then
		return object.power / 30
	end
	local n, u = s:match "^(%d+%.?%d*)([kMG]?)W$"
	assert(n, "Need power : nW")
	return number_conversion(n,u) / UPS
end)

register_unit("energy", "float", function(s, object)
	if s == nil then
		return object.power * 2
	end
	local n, u = s:match "^(%d+%.?%d*)([kMG]?)J$"
	assert(n, "Need energy : nJ")
	return number_conversion(n,u)
end)

local function check_number(s)
	if type(s) == "number" then
		return s
	else
		local n, u = s:match "^(%d+%.?%d*)([kMG]?)$"
		assert(n, "Need a number")
		return number_conversion(n,u)
	end
end

register_unit("number", "float", check_number)

register_unit("count", "int", function(s)
	return check_number(s) | 0
end)

register_unit("percentage", "float", function(s)
	if type(s) == "number" then
		return s
	else
		local p = s:match "^(%-?%d+%.?%d*)%%$"
		assert(p, "Need percentage : n%")
		return p / 100
	end
end)

register_unit("time", "word", function(s)
	if type(s) == "number" then
		local tick = math.floor(s)
		return tick
	end
	if s:match "^[%d.]+s$" then
		local time = assert(tonumber(s:sub(1, -2)))
		local tick = math.floor(time*50)
		return tick
	end
	if s:match "^[%d]+$" then
		local tick = assert(tonumber(s))
		return tick
	end
	error("Invalid time")
end)

local size_cache = setmetatable( {}, { __index = function(c, key)
	assert(type(key) == "string", "Need size *x*")
	local w, h = key:match "(%d)x(%d)"
	assert(w, "Need size *x*")
	w = w + 0
	h = h + 0
	assert(w > 0 and w < 256)
	assert(h > 0 and h < 256)
	local v = w << 8 | h
	c[key] = v
	return v
end })


register_unit("size", "word", function(s)
	return size_cache[s]
end)

register_unit("text", "string", function(s)
	-- todo : localization
	assert(type(s) == "string")
	return s
end)

register_unit("filter", "string", function(s)
	assert(type(s) == "string")
	return s
end)

register_unit("items", "string", function(s)
	local r = {}
	for _, t in ipairs(s) do
		local what = prototype.query("item", t[1])
		r[#r+1] = string.pack("<I2I2", what.id, t[2])
	end
	return table.concat(r)
end)

local enum = {
	priority = {
		primary = 0,
		secondary = 1,
	},
	-- fuel -> heat : reactor
	-- heat -> steam : exchanger
	-- fuel -> steam : boiler
	-- fuel -> electricity : generator
	-- steam -> electricity : turbine
	-- electricity -> steam  : electric boiler
	energy_type = {
		fuel = 0,	-- including steam
		electricity = 1,
		heat = 2,
	},
	burner_type = {
		solid = 0,
		fluid = 1,
		heat = 2,
	},
	fuel_type = {
		chemical = 0,
		nuclear = 1,
		antimatter = 2,
	},
}

local function register_enum(tname)
	return function(name)
		local p = enum[tname][name]
		if p == nil then
			error(string.format("Invalid %s for the type %s", name, tname))
		end
		return p
	end
end

for name in pairs(enum) do
	register_unit(name, "int", register_enum(name))
end
