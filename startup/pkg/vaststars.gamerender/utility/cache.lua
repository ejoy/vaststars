local EMPTY_TABLE = {}
local support_types = {["string"] = true, ["number"] = true, ["boolean"] = true}

local function _sync_cache(self, obj, field_name)
	local key = assert(obj[self.key_field_name])
	local value = obj[field_name]
	if value == nil then
		return
	end

	assert(support_types[type(value)])
	self.cache[field_name] = self.cache[field_name] or {}
	self.cache[field_name][value] = self.cache[field_name][value] or {}
	self.cache[field_name][value][key] = true
end

local function set(self, obj)
	local key = assert(obj[self.key_field_name])
	self.objs[key] = obj

	for field_name in pairs(self.index_field_names) do
		_sync_cache(self, obj, field_name)
	end
end

local function remove(self, key)
	assert(self.objs[key])
	self.objs[key] = nil
end

local function sync(self, syncobj, ...)
	local key = assert(syncobj[self.key_field_name])
	local obj = self.objs[key] or error(("duplicate key `%s`"):format(key))

	local field_names = {...}
	assert(#field_names >= 1)
	for _, field_name in ipairs(field_names) do
		assert(type(field_name) == "string")
		obj[field_name] = syncobj[field_name]

		if self.index_field_names[field_name] then
			_sync_cache(self, obj, field_name)
		end
	end
end

local function select(self, field_name, value)
	assert(value ~= nil)
	local _ = self.index_field_names[field_name] or error(("must specify the field_name `%s` as index field name"):format(field_name))

	if not self.cache[field_name] then
		return next, EMPTY_TABLE, nil
	end

	if not self.cache[field_name][value] then
		return next, EMPTY_TABLE, nil
	end

	local obj
	local result = {}
	for key in pairs(self.cache[field_name][value]) do
		obj = self.objs[key]
		if not obj then
			self.cache[field_name][value][key] = nil
		else
			if obj[field_name] ~= value then
				self.cache[field_name][value][key] = nil
			else
				result[key] = obj
			end
		end
	end

	return next, result, nil
end

local function selectkey(self, key)
	return self.objs[key]
end

local function selectall(self)
    return next, self.objs, nil
end

local function empty(self)
	return not next(self.objs)
end

local function clear(self)
	self.objs = {}
	self.cache = {}
end

return function(key_field_name, ...)
	local m = {}
	m.key_field_name = key_field_name
	m.index_field_names = {}
	for _, field_name in ipairs({...}) do
		m.index_field_names[field_name] = true
	end
	m.objs = {}
	m.cache = {}

	m.set = set
	m.remove = remove
	m.sync = sync
	m.select = select
	m.selectkey = selectkey
	m.selectall = selectall
	m.empty = empty
	m.clear = clear
	return m
end
