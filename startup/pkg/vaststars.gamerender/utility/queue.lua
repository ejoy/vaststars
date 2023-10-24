local function push(self, v)
	self[self.tail] = v
	self.tail = self.tail + 1
end

local function pop(self)
	if self.head == self.tail then
		self.head = 1
		self.tail = 1
		return nil
	else
		local r = self[self.head]
		self[self.head] = nil
		self.head = self.head + 1
		return r
	end
end

local function size(self)
	if self.tail - self.head <= 0 then
		return 0
	else
		return self.tail - self.head
	end
end

local function create()
	local q = {head = 1, tail = 1}
	q.push = push
	q.pop = pop
	q.size = size
	return q
end
return create