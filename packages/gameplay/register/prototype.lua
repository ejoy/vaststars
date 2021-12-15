local status = require "status"

local unit = status.unit
local types = status.types
local id_lookup = status.prototype_id
local name_lookup = status.prototype_name

local function hashstring(s)
	local h = #s
	local b = { string.byte(s, 1, h) }
	for i = 1, h do
		h = h ~ ((h<<5) + (h>>2) + b[i])
	end
	return h
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

return function (name)
	return function (object)
		local typelist = assert(object.type)
		local cache_key = table.concat(typelist, ":")
		local combine_keys = ckeys[cache_key](typelist)
		local namekey = object.type[1] .. "::" .. name
		object.name = name
		local id = object.id
		if not id then
			id = (hashstring(namekey) & 0x3fff) | 0x4000
			object.id = id
		else
			object.id = id | 0
			assert(id > 0 and id <= 0x3fff)
		end
		assert(name_lookup[namekey] == nil)
		assert(id_lookup[id] == nil)
		for _, key in ipairs(combine_keys) do
			local v = object[key.key]
			v = unit[key.unit].converter(v, object)
			if v == nil then
				error (string.format("Missing .%s", key.key))
			end
			object[key.key] = v
		end
		name_lookup[namekey] = object
		id_lookup[id] = object
	end
end
