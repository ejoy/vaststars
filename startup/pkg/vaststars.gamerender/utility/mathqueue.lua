local matharray = require "utility.matharray"

local function push(self, t)
	if self.array == nil then
		self.array = matharray.matrix(t)
	else
		self.array = matharray.append(self.array, t)
	end
	self.tail = self.tail + #t
end

local function pop(self)
	if self.head == self.tail then
		self.head = 1
		self.tail = 1
		self.array = nil
		return nil
	else
		if not self.array then
			return nil
		end
		local r = self.array[self.head]
		self.head = self.head + 1
		if self.head == self.tail then
			self.head = 1
			self.tail = 1
			self.array = nil
		end
		return r
	end
end

local function clear(self)
	self.head = 1
	self.tail = 1
	self.array = nil
end

local function size(self)
	if self.tail - self.head <= 0 then
		return 0
	else
		return self.tail - self.head
	end
end

local function create()
	local q = {head = 1, tail = 1, array = nil}
	q.push = push
	q.pop = pop
	q.size = size
	q.clear = clear
	return q
end
return create