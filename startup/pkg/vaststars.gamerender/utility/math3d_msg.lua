local math3d = require "math3d"

local byte = string.byte
local tochar = string.char
local mark = math3d.mark
local unmark = math3d.unmark

local function close_msg(msg)
	local cidx = msg.__cidx
	for i = 1, #cidx do
		local v = msg[byte(cidx, i)]
		unmark(v)
	end
end

local function create(...)
	local r = { close = close_msg, __cidx = nil, ...}
	local m = ""
	for i = 2, #r do
		local v = r[i]
		if type(v) == "userdata" then
			r[i] = mark(v)
			m = m .. tochar(i)
		end
	end
	r.__cidx = m
	return r
end

return create