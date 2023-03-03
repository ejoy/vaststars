local status = require "status"

local unit = status.unit
local types = status.types
local typefuncs = status.typefuncs
local id_lookup = status.prototype_id
local name_lookup = status.prototype_name

local function hashstring(s)
	local sz = #s
	local h = sz
	local b = { string.byte(s, 1, sz) }
	for i = 1, sz do
		h = h ~ ((h<<5) + (h>>2) + b[i])
	end
	return h
end

local maxid = 0
local function getid(name)
	local hash = hashstring(name) & 0xF000
	maxid = maxid + 1
	if maxid > 0xFFF then
		error "Too many prototype"
	end
	return maxid | hash
end

local function gen_union(list)
	local keys = {}
	local mark = {}
	for _, v in ipairs(list) do
		local typeobject = types[v]
		for _, key in ipairs(typeobject) do
			local unit = mark[key.key]
			if unit == nil then
				mark[key.key] = key.unit
				keys[#keys+1] = key
			elseif unit ~= key.unit then
				error(string.format("Invalid unit %s for .%s" , key.unit, key.key))
			end
		end
	end
	return keys
end

local function keys_union(cache, key)
	local r
	local f = function(list)
		if r then
			return r
		end

		for _, v in ipairs(list) do
			if types[v] == nil then
				error("Unknown type :" .. v)
			end
		end

		local slist = table.move(list, 1, #list, 1, {})
		table.sort(slist)
		local skey = table.concat(slist, ":")
		if skey == key then
			-- It's a sorted list
			r = gen_union(slist)
		else
			r = cache[skey](slist)
		end
		return r
	end
	cache[key] = f
	return f
end

local ckeys = setmetatable({}, { __mode = "kv", __index = keys_union })

local function init(object)
	local typelist = assert(object.type)
	for i = #typelist, 1, -1 do
		local type = typelist[i]
		local funcs = typefuncs[type]
		if funcs and funcs.init then
			for k, v in pairs(funcs.init()) do
				if object[k] == nil then
					object[k] = v
				end
			end
		end
	end
end

local function array_exist(a, v)
	for _, av in ipairs(a) do
		if av == v then
			return true
		end
	end
	return false
end

local function array_append(t, a)
	table.move(a, 1, #a, #t+1, t)
end

local function array_merge(a, b)
	local c = {}
	for _, bv in ipairs(b) do
		if not array_exist(a, bv) then
			c[#c+1] = bv
		end
	end
	array_append(a, b)
end

local function equals(a, b)
	local ta = type(a)
    if ta ~= 'table' then
        return a == b
    end
    if ta ~= type(b) then
        return false
    end
    for k, v in pairs(a) do
        if not equals(v, b[k]) then
            return false
        end
    end
    for k, v in pairs(b) do
        if not equals(a[k], v) then
            return false
        end
    end
    return true
end

return function (name)
	return function (object)
		init(object)
		local typelist = assert(object.type)
		local cache_key = table.concat(typelist, ":")
		local combine_keys = ckeys[cache_key](typelist)
		for _, key in ipairs(combine_keys) do
			local v = object[key.key]
			local ok, r, errmsg = pcall(unit[key.unit].converter, v, object)
			if not ok then
				error(string.format("Error format .%s in %s", key.key, name))
			end
			if r == nil then
				error(string.format(".%s in %s: %s", key.key, name, errmsg))
			end
			object[key.key] = r
		end
		local oldobject = name_lookup[name]
		if oldobject == nil then
			local id = getid(name)
			if id_lookup[id] ~= nil then
				local o = id_lookup[id]
				error(("Duplicate id: %s %s"):format(name, "("..o.type[1]..")"..o.name))
			end
			object.name = name
			object.id = id
			name_lookup[name] = object
			id_lookup[object.id] = object
		else
			for k, v in pairs(object) do
				if oldobject[k] == nil then
					oldobject[k] = v
				elseif k == "type" then
					array_merge(oldobject[k], v)
				elseif equals(oldobject[k], v) then
					--ignore same
				else
					error(string.format("`%s` has duplicate key `%s`.", name, k))
				end
			end
		end
	end
end
