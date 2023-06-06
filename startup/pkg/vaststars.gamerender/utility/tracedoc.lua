local next = next
local pairs = pairs
local setmetatable = setmetatable
local getmetatable = getmetatable
local type = type
local rawset = rawset
local table = table

local tracedoc = {}
local NULL = setmetatable({} , { __tostring = function() return "NULL" end })	-- nil
tracedoc.null = NULL
local tracedoc_type = setmetatable({}, { __tostring = function() return "TRACEDOC" end })
local tracedoc_len = setmetatable({} , { __mode = "kv" })

local function doc_next(doc, key)
	-- at first, iterate all the keys changed
	local change_keys = doc._keys
	if key == nil or change_keys[key] then
		while true do
			key = next(change_keys, key)
			if key == nil then
				break
			end
			local v = doc[key]
			if v ~= nil then
				return key, v
			end
		end
	end

	-- and then, iterate all the keys in lastversion except keys changed

	local lastversion = doc._lastversion

	while true do
		key = next(lastversion, key)
		if key == nil then
			return
		end
		if not change_keys[key] then
			local v = doc[key]
			if v ~= nil then
				return key, v
			end
		end
	end
end

local function doc_pairs(doc)
	return doc_next, doc
end

local function find_length_after(doc, idx)
	local v = doc[idx + 1]
	if v == nil then
		return idx
	end
	repeat
		idx = idx + 1
		v = doc[idx + 1]
	until v == nil
	tracedoc_len[doc] = idx
	return idx
end

local function find_length_before(doc, idx)
	if idx <= 1 then
		tracedoc_len[doc] = nil
		return 0
	end
	repeat
		idx = idx - 1
	until idx <=0 or doc[idx] ~= nil
	tracedoc_len[doc] = idx
	return idx
end

local function doc_len(doc)
	local len = tracedoc_len[doc]
	if len == nil then
		len = #doc._lastversion
		tracedoc_len[doc] = len
	end
	if len == 0 then
		return find_length_after(doc, 0)
	end
	local v = doc[len]
	if v == nil then
		return find_length_before(doc, len)
	end
	return find_length_after(doc, len)
end

local function doc_read(doc, k)
	if doc._keys[k] then
		return doc._changes[k]
	end
	-- if k is not changed, return lastversion
	return doc._lastversion[k]
end

local function doc_change(doc, k, v)
	local function make_dirty(doc)
		doc._dirty = true
		local parent = doc._parent
		while parent do
			if getmetatable(parent) ~= tracedoc_type then
				break
			end
			if parent._dirty then
				break
			end
			parent._dirty = true
			parent = parent._parent
		end
	end

	if type(v) == "table" then
		local vt = getmetatable(v)
		if vt == nil then
			local lv = doc._lastversion[k]
			if getmetatable(lv) ~= tracedoc_type then
				-- last version is not a table, new a empty one
				lv = tracedoc.new()
				lv._dirty = true
				lv._parent = doc
				doc._lastversion[k] = lv
			elseif doc[k] == nil then
				-- this version is clear first, deepcopy lastversion one
				lv = tracedoc.new(lv)
				lv._dirty = true
				lv._parent = doc
				doc._lastversion[k] = lv
			end
			local keys = {}
			for k in pairs(lv) do
				keys[k] = true
			end
			-- deepcopy v
			for k,v in pairs(v) do
				lv[k] = v
				if not doc._dirty then
					doc._dirty = lv._dirty
				end
				keys[k] = nil
			end
			-- clear keys not exist in v
			for k in pairs(keys) do
				lv[k] = nil
			end
			-- don't cache sub table into doc._changes
			doc._changes[k] = nil
			doc._keys[k] = nil
			return
		end
	end
	if doc[k] ~= v then
		make_dirty(doc)
		doc._changes[k] = v
		doc._keys[k] = true
	end
end

local doc_mt = {
	__newindex = doc_change,
	__index = doc_read,
	__pairs = doc_pairs,
	__len = doc_len,
	__metatable = tracedoc_type,	-- avoid copy by ref
}

function tracedoc.new(init)
	local doc = {
		_dirty = false,
		_parent = false,
		_changes = {},
		_keys = {},
		_lastversion = {},
	}
	setmetatable(doc, doc_mt)
	if init then
		for k,v in pairs(init) do
			-- deepcopy v
			if getmetatable(v) == tracedoc_type then
				doc[k] = tracedoc.new(v)
			else
				doc[k] = v
			end
		end
	end
	return doc
end

function tracedoc.dump(doc)
	local last = {}
	for k,v in pairs(doc._lastversion) do
		table.insert(last, string.format("%s:%s",k,v))
	end
	local changes = {}
	for k,v in pairs(doc._changes) do
		table.insert(changes, string.format("%s:%s",k,v))
	end
	local keys = {}
	for k in pairs(doc._keys) do
		table.insert(keys, k)
	end
	return string.format("last [%s]\nchanges [%s]\nkeys [%s]",table.concat(last, " "), table.concat(changes," "), table.concat(keys," "))
end

function tracedoc.commit(doc, result, prefix)
	if doc._ignore then
		return result
	end
	doc._dirty = false
	local lastversion = doc._lastversion
	local changes = doc._changes
	local keys = doc._keys
	local dirty = false
	if next(keys) ~= nil then
		for k in next, keys do
			local v = changes[k]
			keys[k] = nil
			changes[k] = nil
			if lastversion[k] ~= v then
				dirty = true
				if result then
					local key = prefix and prefix .. k or k
					result[key] = v == nil and NULL or v
					result._n = (result._n or 0) + 1
				end
				lastversion[k] = v
			end
		end
	end
	for k,v in pairs(lastversion) do
		if getmetatable(v) == tracedoc_type and v._dirty then
			if result then
				local key = prefix and prefix .. k or k
				local change
				if v._opaque then
					change = tracedoc.commit(v)
				else
					local n = result._n
					tracedoc.commit(v, result, key .. ".")
					if n ~= result._n then
						change = true
					end
				end
				if change then
					if result[key] == nil then
						result[key] = v
						result._n = (result._n or 0) + 1
					end
					dirty = true
				end
			else
				local change = tracedoc.commit(v)
				dirty = dirty or change
			end
		end
	end
	return result or dirty
end

function tracedoc.ignore(doc, enable)
	rawset(doc, "_ignore", enable)	-- ignore it during commit when enable
end

function tracedoc.opaque(doc, enable)
	rawset(doc, "_opaque", enable)
end

----- change set

local function genkey(keys, key)
	if keys[key] then
		return
	end
	key = key:gsub("(%.)(%d+)","[%2]")
	key = key:gsub("^(%d+)","[%1]")
	keys[key] = assert(load ("return function(doc) return doc.".. key .." end"))()
end

local function insert_tag(tags, tag, item, n)
	local v = { table.unpack(item, n, #item) }
	local t = tags[tag]
	if not t then
		tags[tag] = { v }
	else
		table.insert(t, v)
	end
	return v
end

function tracedoc.changeset(map)
	local set = {
		watching_n = 0,
		watching = {} ,
		mapping = {} ,
		keys = {},
		tags = {},
	}
	for _,v in ipairs(map) do
		local tag = v[1]
		if type(tag) == "string" then
			v = insert_tag(set.tags, tag, v, 2)
		else
			v = insert_tag(set.tags, "", v, 1)
		end

		local n = #v
		if n == 1 then
			v[#v+1] = tag
			n = #v
		end
		assert(n >=2 and type(v[1]) == "function")
		if n == 2 then
			local f = v[1]
			local k = v[2]
			local tq = type(set.watching[k])
			genkey(set.keys, k)
			if tq == "nil" then
				set.watching[k] = f
				set.watching_n = set.watching_n + 1
			elseif tq == "function" then
				local q = { set.watching[k], f }
				set.watching[k] = q
			else
				assert (tq == "table")
				table.insert(set.watching[k], f)
			end
		else
			table.insert(set.mapping, { table.unpack(v) })
			for i = 2, #v do
				genkey(set.keys, v[i])
			end
		end
	end
	return set
end

local function do_funcs(doc, funcs, v)
	if v == NULL then
		v = nil
	end
	if type(funcs) == "function" then
		funcs(doc, v)
	else
		for _, func in ipairs(funcs) do
			func(doc, v)
		end
	end
end

local function do_mapping(doc, mapping, changes, keys, args)
	local n = #mapping
	for i=2,n do
		local key = mapping[i]
		local v = changes[key]
		if v == nil then
			v = keys[key](doc)
		elseif v == NULL then
			v = nil
		end
		args[i-1] = v
	end
	mapping[1](doc, table.unpack(args,1,n-1))
end

function tracedoc.mapchange(doc, set, c)
	local changes = tracedoc.commit(doc, c or {})
	local changes_n = changes._n or 0
	if changes_n == 0 then
		return changes
	end
	if changes_n > set.watching_n then
		-- a lot of changes
		for key, funcs in pairs(set.watching) do
			local v = changes[key]
			if v ~= nil then
				do_funcs(doc, funcs, v)
			end
		end
	else
		-- a lot of watching funcs
		local watching_func = set.watching
		for key, v in pairs(changes) do
			local funcs = watching_func[key]
			if funcs then
				do_funcs(doc, funcs, v)
			end
		end
	end
	-- mapping
	local keys = set.keys
	local tmp = {}
	for _, mapping in ipairs(set.mapping) do
		for i=2,#mapping do
			local key = mapping[i]
			if changes[key] ~= nil then
				do_mapping(doc, mapping, changes, keys, tmp)
				break
			end
		end
	end
	return changes
end

function tracedoc.mapupdate(doc, set, filter_tag)
	local args = {}
	local keys = set.keys
	for tag, items in pairs(set.tags) do
		if tag == filter_tag or filter_tag == nil then
			for _, mapping in ipairs(items) do
				local n = #mapping
				for i=2,n do
					local key = mapping[i]
					local v = keys[key](doc)
					args[i-1] = v
				end
				mapping[1](doc, table.unpack(args,1,n-1))
			end
		end
	end
end

function tracedoc.diff(doc)
	local changeset = {}
	for k in pairs(doc._keys) do
		local v = doc._changes[k]
		if v == nil then
			changeset.del = changeset.del or {}
			changeset.del[#changeset.del + 1] = k
		else
			changeset.mod = changeset.mod or {}
			changeset.mod[k] = v
		end
	end
	for k,v in pairs(doc._lastversion) do
		if getmetatable(v) == tracedoc_type and v._dirty then
			changeset.doc = changeset.doc or {}
			changeset.doc[k] = tracedoc.diff(v)
			if not changeset.doc[k] and tracedoc.changed(v) then
				changeset.doc[k] = {}
			end
		end
	end
	if not next(changeset) then
		return
	end
	return changeset
end

function tracedoc.patch(doc, diff)
	if not diff then
		return
	end

	if diff.doc then
		for k, v in pairs(diff.doc) do
			if not doc[k] then
				doc[k] = tracedoc.new({})
				doc[k]._parent = doc
			end
			tracedoc.patch(doc[k], v)
		end
	end

	if diff.del then
		for _, k in ipairs(diff.del) do
			doc[k] = nil
		end
	end

	if diff.mod then
		for k, v in pairs(diff.mod) do
			doc[k] = v
		end
	end
end

function tracedoc.changed(doc)
	return doc._dirty
end

return tracedoc
