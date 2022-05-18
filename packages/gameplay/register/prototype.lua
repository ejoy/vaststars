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

local maintype = {
	entity = {
		maxid = 0,
		magic = 0x0000,
	},
	item = {
		maxid = 0,
		magic = 0x0200,
	},
	recipe = {
		maxid = 0,
		magic = 0x0400,
	},
	tech = {
		maxid = 0,
		magic = 0x0600,
	},
	fluid = {
		maxid = 0,
		magic = 0x0C00,
	},
}
local function getid(mainkey, name)
	local m = assert(maintype[mainkey])
	local hash = hashstring(name) & 0xF000
	m.maxid = m.maxid + 1
	if m.maxid > 0x1FF then
		error "Too many prototype"
	end
	return m.maxid | m.magic | hash
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
		local mainkey = object.type[1]
		local namekey = "("..mainkey..")"..name
		if name_lookup[namekey] ~= nil then
			local o = name_lookup[namekey]
			error(("Duplicate %s: %s"):format(o.type[1], o.name))
		end
		local id = getid(mainkey, name)
		if id_lookup[id] ~= nil then
			local o = id_lookup[id]
			error(("Duplicate id: %s %s"):format(namekey, "("..o.type[1]..")"..o.name))
		end
		object.name = name
		object.id = id
		for _, key in ipairs(combine_keys) do
			local v = object[key.key]
			local ok, r, errmsg = pcall(unit[key.unit].converter, v, object)
			if not ok then
				error(string.format("Error format .%s in %s", key.key, namekey))
			end
			if r == nil then
				error(string.format(".%s in %s: %s", key.key, namekey, errmsg))
			end
			object[key.key] = r
		end
		name_lookup[namekey] = object
		id_lookup[id] = object
	end
end
