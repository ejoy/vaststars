local math3d = require "math3d"
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant

local srt = {}

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
		s = mark(math3d.vector(init.s or mc.ONE)),
		r = mark(math3d.quaternion(init.r or mc.IDENTITY_QUAT)),
		t = mark(math3d.vector(init.t or mc.ZERO_PT)),
	}
	return setmetatable({ raw = v }, {
		__index = v,
		__newindex = access_srt,
		__gc = unmark_srt,
		__tostring = tostring_srt,
	})
end

return srt
