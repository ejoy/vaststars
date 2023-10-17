local math3d = require "math3d"

local srt = {}

local scale_1 <const> = math3d.constant("v4", 1,1,1,1)
local quat_i <const> = math3d.constant "quat"
local trans_0 <const> = math3d.constant("v4", 0,0,0,1)

local unmark = math3d.unmark
local mark = math3d.mark

local converter = {
	s = math3d.vector,
	r = math3d.quaternion,
	t = math3d.vector,
}

local function access_srt(o, key, v)
	local raw = o.raw
	local mv = mark(converter[key](v))
	unmark(raw[key])
	raw[key] = mv
end

local function unmark_srt(o)
	local v = o.raw
	unmark(v.s)
	unmark(v.r)
	unmark(v.t)
	v.s = nil
	v.r = nil
	v.t = nil
end

local function tostring_srt(o)
	local v = o.raw
	return string.format("[%s %s %s]",
		math3d.tostring(v.s),
		math3d.tostring(v.r),
		math3d.tostring(v.t))
end

function srt.new(init)
	local v = {
		s = math3d.vector(init.s or scale_1),
		r = math3d.quaternion(init.r or quat_i),
		t = math3d.vector(init.t or trans_0),
	}
	return setmetatable({ raw = v }, {
		__index = v,
		__newindex = access_srt,
		__gc = unmark_srt,
		__tostring = tostring_srt,
	})
end

return srt
