local math3d = require "math3d"

local array = {}

local mark = math3d.mark
local unmark = math3d.unmark
local array_index = math3d.array_index

local array_meta = {}

function array_meta:__len()
	return self.n
end

function array_meta:__index(i)
	if i <= 0 or i > self.n then
		return
	else
		return array_index(self._array, i)
	end
end

function array_meta:__gc()
	unmark(self._array)
	self._array = nil
	self.n = nil
end

function array_meta:__tostring()
	return math3d.tostring(self._array)
end

local function ctor(type)
	local array_ctor = assert(math3d["array_" .. type])
	return function (s)
		local o = {}
		if s._array then
			assert(s.type == type)
			o._array = mark(s._array)
		else
			o._array = mark(array_ctor(s))
		end
		o.n = math3d.array_size(o._array)
		o.type = type
		return setmetatable(o, array_meta)
	end
end

array.vector = ctor "vector"
array.matrix = ctor "matrix"
array.quat = ctor "quat"

--[[

local v = array.vector {
	{ 1,2,3,4 },
	{ 5,6,7,8 },
}

print(v, #v)

for i, v in ipairs(v) do
	print(i,math3d.tostring(v))
end

]]


return array
