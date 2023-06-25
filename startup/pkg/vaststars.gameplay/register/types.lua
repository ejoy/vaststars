local status = require "status"
local prototype = require "prototype"

local unit = status.unit

local UPS <const> = 30

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
		return nil, ("Invalid postfix " .. u)
	end
	return math.floor(n)
end

register_unit("power", "integer", function(s)
	if s == nil then
		return
	end
	local n, u = s:match "^(%d+%.?%d*)([kMG]?)W$"
	if not n then
		return nil, "Need power : nW"
	end
	return number_conversion(n,u) // UPS
end)

register_unit("energy", "integer", function(s)
	if s == nil then
		return
	end
	local n, u = s:match "^(%d+%.?%d*)([kMG]?)J$"
	if not n then
		return nil, "Need energy : nJ"
	end
	return number_conversion(n,u)
end)

local function check_integer(s)
	if type(s) == "number" then
		return math.floor(s)
	end
	local n, u = s:match "^(%d+%.?%d*)([kMG]?)$"
	if not n then
		return nil, "Need a integer"
	end
	return number_conversion(n,u)
end

register_unit("integer", "integer", check_integer)

register_unit("percentage", "float", function(s)
	if s == nil then
		return 1.0
	end
	if type(s) == "number" then
		return s
	end
	local p = s:match "^(%-?%d+%.?%d*)%%$"
	if not p then
		return nil, "Need percentage : n%"
	end
	return p / 100
end)

register_unit("time", "integer", function(s)
	if s == nil then
		return
	end
	if type(s) == "number" then
		return math.floor(s)
	end
	if s:match "^[%d.]+s$" then
		local time = assert(tonumber(s:sub(1, -2)))
		local tick = math.floor(time*UPS)
		return tick
	end
	if s:match "^[%d]+$" then
		local tick = assert(tonumber(s))
		return tick
	end
	return nil, "Invalid time"
end)

register_unit("size", "integer", function(s)
	if type(s) ~= "string" then
		return nil, "Need size *x*"
	end
	local w, h = s:match "(%d)x(%d)"
	if not w then
		return nil, "Need size *x*"
	end
	w = w + 0
	h = h + 0
	assert(w > 0 and w < 256)
	assert(h > 0 and h < 256)
	local v = w << 8 | h
	return v
end)

register_unit("position", "integer", function(s)
	if type(s) ~= "string" then
		return nil, "Need position *,*"
	end
	local x, y = s:match "(%d),(%d)"
	if not x then
		return nil, "Need size *,*"
	end
	x = x + 0
	y = y + 0
	assert(x >= 0 and x < 256)
	assert(y >= 0 and y < 256)
	local v = y << 8 | x
	return v
end)

local _ <const> = 0
local L <const> = 1 << 0
local T <const> = 1 << 1
local R <const> = 1 << 2
local B <const> = 1 << 3
local RoadMask <const> = {
	[utf8.codepoint '║'] = _|T|_|B,
	[utf8.codepoint '═'] = L|_|R|_,
	[utf8.codepoint '╔'] = _|_|R|B,
	[utf8.codepoint '╠'] = _|T|R|B,
	[utf8.codepoint '╚'] = _|T|R|_,
	[utf8.codepoint '╦'] = L|_|R|B,
	[utf8.codepoint '╬'] = L|T|R|B,
	[utf8.codepoint '╩'] = L|T|R|_,
	[utf8.codepoint '╗'] = L|_|_|B,
	[utf8.codepoint '╣'] = L|T|_|B,
	[utf8.codepoint '╝'] = L|T|_|_,
	[utf8.codepoint '>'] = L|_|_|_,
	[utf8.codepoint 'v'] = _|T|_|_,
	[utf8.codepoint '<'] = _|_|R|_,
	[utf8.codepoint '^'] = _|_|_|B,
}

register_unit("network", "string", function(s)
	local r = {}
	for _, t in ipairs(s) do
		local x, y, m = t:match "(%d),(%d),(.*)"
		if not x then
			return nil, "invalid road format"
		end
		x = x + 0
		y = y + 0
		assert(y >= 0 and y < 256)
		for _, c in utf8.codes(m) do
			assert(x >= 0 and x < 256)
			r[#r+1] = string.pack("<I1I1I1", x, y, RoadMask[c])
			x = x + 2
		end
	end
	return table.concat(r)
end)

register_unit("text", "string", function(s)
	-- todo : localization
	assert(type(s) == "string")
	return s
end)

local function query(t, v)
	if t == "raw" then
		return tonumber(v)
	end
	local what = prototype.queryByName(v)
	if what then
		return what.id
	end
end

register_unit("itemtypes", "string", function(s)
	local r = {string.pack("<I2", #s)}
	for _, t in ipairs(s) do
		local id = query("item/fluid", t)
		if id then
			r[#r+1] = string.pack("<I2", id)
		else
			return nil, "Unkonwn item/fluid: " .. t
		end
	end
	return table.concat(r)
end)
unit["itemtypes"].lazy = true

register_unit("items", "string", function(s)
	local r = {string.pack("<I4", #s)}
	for _, t in ipairs(s) do
		local id = query("item/fluid", t[1])
		if id then
			r[#r+1] = string.pack("<I2I2", id, t[2])
		else
			return nil, "Unkonwn item/fluid: " .. t[1]
		end
	end
	return table.concat(r)
end)
unit["items"].lazy = true

register_unit("fluidbox", "table", function(s)
	return s
end)

local TaskSchema <const> = {
	stat_production = {0, "raw", "item/fluid"},
	stat_consumption = {1, "raw", "item/fluid"},
	select_entity = {2, "raw", "building"},
	power_generator = {4, "raw"},
	unknown = {5, "raw", "raw"},
}
local TaskMaxArgsCount = 0
for _, v in pairs(TaskSchema) do
	TaskMaxArgsCount = math.max(TaskMaxArgsCount, #v)
end

register_unit("task", "string", function(args)
	local schema = TaskSchema[args[1]]
	if not schema then
		return nil, "Unkonwn task type: " .. args[1]
	end
	local r = {schema[1]}
	for i = 2, #schema do
		local id = query(schema[i], args[i])
		if not id then
			return nil, "Unkonwn "..schema[i]..": " .. args[i]
		end
		r[i] = id
	end
	for i = 1, TaskMaxArgsCount do
		r[i] = string.pack("<I2", r[i] or 0)
	end
	return table.concat(r)
end)
unit["task"].lazy = true

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
	chest_type = {
		red = 0,
		blue = 1,
		green = 2,
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
	register_unit(name, "integer", register_enum(name))
end
