local tinsert = table.insert
local pairs = pairs
local setmetatable = setmetatable
local next = next

local syncobj = {}
local weak_meta = { __mode = "kv" }

local source = {} ; source.__index = source

local function object_newindex(self, key, value)
	self.__real[key] = value
	self.__change[key] = value
end

local function object_pairs(self)
	return next, self.__real, nil
end

function source:new(init)
	local obj = {
		__real = {},
		__last = {},
		__change = {},
		__changeset = { self.id },
	}
	self.id_list[self.id] = self.id_mark
	self.cache[self.id] = obj
	self.id = self.id + 1
	setmetatable(obj, {
		__index = obj.__real,
		__pairs = object_pairs,
		__newindex = object_newindex,
	})
	if init then
		for k,v in pairs(init) do
			obj[k] = v
		end
	end
	return obj
end

function source:diff(obj)
	local i = 2
	local last = obj.__last
	local changeset = obj.__changeset
	local change = obj.__change
	local len = #changeset
	for k,v in pairs(change) do
		if last[k] ~= v then
			changeset[i] = k
			changeset[i+1] = v
			i = i + 2
		end
		change[k] = nil
	end
	local real = obj.__real
	local remove
	for k,v in pairs(last) do
		if real[k] == nil then
			remove = remove or {}
			tinsert(remove, k)
		end
		last[k] = nil
	end
	for k,v in pairs(real) do
		last[k] = real[k]
	end
	changeset[i] = remove
	for j = i+1, len do
		changeset[j] = nil
	end
	return changeset
end

function source:changed(obj)
	return (next(obj.__change) ~= nil)
end

function source:reset(obj)
	obj.__last = {}
	obj.__change = {}
	local lastid = obj.__changeset[1]
	local changeset = { self.id }
	self.cache[lastid] = nil
	self.cache[self.id] = obj
	self.id = self.id + 1
	obj.__changeset = changeset
	for k,v in pairs(obj.__real) do
		tinsert(changeset, k)
		tinsert(changeset, v)
	end
	return changeset
end

function source:collect()
	local mark = not self.id_mark
	self.id_mark = mark
	local id_list = self.id_list
	for id in pairs(self.cache) do
		id_list[id] = mark
	end
	local remove_list
	for k,v in pairs(id_list) do
		if v ~= mark then
			remove_list = remove_list or {}
			tinsert(remove_list, k)
			id_list[k] = nil
		end
	end
	return remove_list
end

function syncobj.source()
	local channel = {
		id = 1,
		id_mark = true,
		id_list = {},
		cache = setmetatable({}, weak_meta),
	}
	return setmetatable(channel, source)
end

local clone = {} ; clone.__index = clone

function clone:patch(diff)
	local id = diff[1]
	local obj = self[id]
	if obj == nil then
		obj = {}
		self[id] = obj
	end
	local n = #diff
	for i = 2, n, 2 do
		obj[diff[i]] = diff[i+1]
	end
	if n % 2 == 0 then
		-- remove keys
		for _, v in ipairs(diff[n]) do
			obj[v] = nil
		end
	end
	return obj
end

function clone:collect(remove_set)
	if remove_set then
		for _, id in ipairs(remove_set) do
			self[id] = nil
		end
	end
end

function syncobj.clone()
	local channel = {}
	return setmetatable(channel, clone)
end

return syncobj
