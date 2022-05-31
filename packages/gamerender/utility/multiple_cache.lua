local create_cache = require "utility.cache"

local function set(self, cache_name, value)
    assert(self.caches[cache_name])
    local key = self.cache_param[1]
    assert(not self.caches[cache_name]:key(key))
    self.caches[cache_name]:set(value)
end

local function get(self, cache_names, key)
    local value
    for _, cache_name in ipairs(cache_names) do
        value = self.caches[cache_name]:key(key)
        if value then
            return value
        end
    end
end

local function commit(self, cache_name_1, cache_name_2)
    local cache_1 = assert(self.caches[cache_name_1])
    local cache_2 = assert(self.caches[cache_name_2])

    for _, v in cache_1:all() do
        cache_2:set(v)
    end
    self.caches[cache_name_1] = create_cache(table.unpack(self.cache_param))
end

local function remove(self, cache_name, key)
    local cache = assert(self.caches[cache_name])
    return cache:remove(key)
end

local function all(self, cache_name)
    local cache = assert(self.caches[cache_name])
    return cache:all()
end

local function select(self, cache_name, index_field, cache_value)
    local cache = assert(self.caches[cache_name])
    return cache:select(index_field, cache_value)
end

local function selectall(self, cache_names, index_field, cache_value)
    local r = {}

    for i = #cache_names, 1, -1 do
        for k, v in select(self, cache_names[i], index_field, cache_value) do
            if not r[k] then
                r[k] = v
            end
        end
    end

    return next, r, nil
end

local function clear(self, cache_names)
    for _, cache_name in ipairs(cache_names) do
        self.caches[cache_name]:clear()
    end
end

local function empty(self, cache_name)
    return self.caches[cache_name]:empty()
end

local function create(cache_names, ...)
    local M = {}
    M.caches = {}
    M.cache_param = {...}

    for _, cache_name in ipairs(cache_names) do
        M.caches[cache_name] = create_cache(table.unpack(M.cache_param))
    end

    M.set = set
    M.get = get
    M.all = all
    M.select = select
    M.selectall = selectall
    M.commit = commit
    M.remove = remove
    M.clear = clear
    M.empty = empty

    return setmetatable(M, {__index = M})
end
return create