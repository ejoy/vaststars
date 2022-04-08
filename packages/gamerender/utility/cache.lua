local EMPTY_TABLE = {}

local function key(self, key)
	return self.kv[key]
end

local function select(self, index_field, cache_value)
	assert(cache_value ~= nil)
	if not self.cache[index_field] then
		return EMPTY_TABLE
	end

	if not self.cache[index_field][cache_value] then
		return EMPTY_TABLE
	end

	local value
	local r = {}
	for key in pairs(self.cache[index_field][cache_value]) do
		value = self.kv[key]
		if not value then
			self.cache[index_field][cache_value][key] = nil
		else
			if value[index_field] ~= cache_value then
				self.cache[index_field][cache_value][key] = nil
			end
		end
		r[key] = value
	end

	return next, r, nil
end

local function all(self)
    return next, self.kv, nil
end

local function set(self, value)
	local key = value[self.key_field]
	self.kv[key] = value

	--
	local cache_value
	for _, index_field in ipairs(self.index_fields) do
		assert(value[index_field] ~= nil)
		cache_value = value[index_field]
		assert(type(cache_value) == "number" or type(cache_value) == "string" or type(cache_value) == "boolean")
		self.cache[index_field] = self.cache[index_field] or {}
		self.cache[index_field][cache_value] = self.cache[index_field][cache_value] or {}
		self.cache[index_field][cache_value][key] = true
	end
end

local function remove(self, key)
	self.kv[key] = nil
end

local function create(key_field, ...)
	local m = {}
	m.key_field = key_field
	m.index_fields = {...}
	m.kv = {}
	m.cache = {}

	m.set = set
	m.key = key
    m.all = all
	m.select = select
	m.remove = remove
	return m
end
return create