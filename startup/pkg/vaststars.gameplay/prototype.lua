local status = require "status"

local m = {}

local unit = status.unit
local types = status.types
local typefuncs = status.typefuncs
local prototype = {}
local lookup = {}
local lazy = {}
local unsolved_name = {}

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
			for k, v in pairs(funcs.init(nil, object)) do
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

local function converter(name, object, key)
	local v = object[key.key]
	local ok, r, errmsg = pcall(unit[key.unit].converter, v)
	if not ok then
		error(string.format("Error format .%s in %s", key.key, name))
	end
	if r == nil then
		return
	end
	object[key.key] = r
end

function m.register(name)
	return function (object)
		local typelist = assert(object.type)
		local cache_key = table.concat(typelist, ":")
		local combine_keys = ckeys[cache_key](typelist)
		for _, key in ipairs(combine_keys) do
			if unit[key.unit].lazy then
				lazy[name] = lazy[name] or {}
				lazy[name][key] = object[key.key]
			else
				converter(name, object, key)
			end
		end
		init(object)
		local oldobject = lookup[name]
		if oldobject == nil then
			object.name = name
			lookup[name] = object
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

function m.queryById(id)
	return prototype[id]
end

function m.queryByName(name)
	return lookup[name]
end

function m.all()
	return prototype
end

function m.unsolved()
	return unsolved_name
end

function m.value(unitname, v)
	return unit[unitname].converter(v)
end

function m.backup()
	local t = {}
	for name, obj in pairs(lookup) do
		t[name] = obj.id
	end
	return t
end

function m.restore(cworld, t)
	prototype = {}
	unsolved_name = {}
	local mark = {}
	local maxid = 0
	for name, id in pairs(t) do
		mark[id] = true
		if not lookup[name] then
			unsolved_name[id] = name
		end
	end
	local function getid()
		while true do
			maxid = maxid + 1
			if not mark[maxid] then
				return maxid
			end
		end
	end
	for name, obj in pairs(lookup) do
		local id = t[name] or getid()
		obj.id = id
		prototype[id] = obj
	end
	for name, obj in pairs(lazy) do
		local object = lookup[name]
		for k, v in pairs(obj) do
			object[k.key] = v
			converter(name, object, k)
		end
	end
	cworld:prototype_bind(prototype)
end

return m
