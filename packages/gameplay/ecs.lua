local ecs = require "ecs.core"

local REFERENCE_ID <const> = 1

local rawerror = error
local selfsource <const> = debug.getinfo(1, "S").source
local function error(errmsg)
	local level = 2
	while true do
		local info = debug.getinfo(level, "S")
		if not info then
			rawerror(errmsg, 2)
			return
		end
		if selfsource ~= info.source then
			rawerror(errmsg, level)
			return
		end
		level = level + 1
	end
end

local function assert(cond, errmsg)
	if not cond then
		error(errmsg or "assertion failed!")
	end
	return cond
end

local function get_attrib(opt, inout)
	if opt == nil then
		return { exist = true }
	end
	local desc = {}
	if opt == "?" then
		desc.opt = true
	else
		assert(opt == ":")
	end
	if inout == "in" then
		desc.r = true
	elseif inout == "out" then
		desc.w = true
	elseif inout == "update" then
		desc.r = true
		desc.w = true
	elseif inout == "exist" then
		desc.exist = true
		assert(not desc.opt)
	elseif inout == "absent" then
		desc.absent = true
		assert(not desc.opt)
	else
		assert(inout == "new")
	end
	return desc
end

local function cache_world(obj, k)
	local c = {
		typenames = {},
		id = 0,
		select = {},
		ref = {},
	}

	local function gen_ref_pat(key)
		local typenames = c.typenames
		local desc = {}
		local tc = typenames[key]
		if tc == nil then
			error("Unknown type " .. key)
		end
		local a = {
			exist = true,
			name = tc.name,
			id = tc.id,
			type = tc.type,
		}
		local n = #tc
		for i=1,#tc do
			a[i] = tc[i]
		end
		desc[1] = a
		return desc
	end

	local function gen_all_pat()
		local desc = {}
		local i = 1
		for name,t in pairs(c.typenames) do
			if t.tag ~= "ORDER" then
				local a = {
					name = t.name,
					id = t.id,
					type = t.type,
					opt = true,
					r = true,
				}
				table.move(t, 1, #t, 1, a)
				desc[i] = a
				i = i + 1
			end
		end
		return desc
	end

	setmetatable(c, { __index = function(_, key)
		if key == "all" then
			local all = k:_groupiter(gen_all_pat())
			c.all = all
			return all
		end
	end })

	local function gen_select_pat(pat)
		local typenames = c.typenames
		local desc = {}
		local idx = 1
		for token in pat:gmatch "[^ ]+" do
			local key, padding = token:match "^([_%w]+)(.*)"
			assert(key, "Invalid pattern")
			local opt, inout
			if padding ~= "" then
				opt, inout = padding:match "^([:?])(%l+)$"
				assert(opt, "Invalid pattern")
			end
			local tc = typenames[key]
			if tc == nil then
				error("Unknown type " .. key)
			end
			local a = get_attrib(opt, inout)
			a.name = tc.name
			a.id = tc.id
			a.type = tc.type
			local n = #tc
			for i=1,#tc do
				a[i] = tc[i]
			end
			desc[idx] = a
			idx = idx + 1
			if tc.ref then
				local dead = typenames[key .. "_dead"]
				local a = {
					absent = true,
					name = dead.name,
					id = dead.id,
				}
				desc[idx] = a
				idx = idx + 1
			end
		end
		return desc
	end

	local function cache_select(cache, pat)
		local pat_desc = gen_select_pat(pat)
		cache[pat] = k:_groupiter(pat_desc)
		return cache[pat]
	end

	setmetatable(c.select, {
		__mode = "kv",
		__index = cache_select,
		})

	local function cache_ref(cache, pat)
		local pat_desc = gen_ref_pat(pat)
		cache[pat] = k:_groupiter(pat_desc)
		return cache[pat]
	end

	setmetatable(c.ref, {
		__mode = "kv",
		__index = cache_ref,
		})

	obj[k] = c
	return c
end

local context = setmetatable({}, { __index = cache_world })
local typeid = {
	int = assert(ecs._TYPEINT),
	float = assert(ecs._TYPEFLOAT),
	bool = assert(ecs._TYPEBOOL),
	int64 = assert(ecs._TYPEINT64),
	dword = assert(ecs._TYPEDWORD),
	word = assert(ecs._TYPEWORD),
	byte = assert(ecs._TYPEBYTE),
	double = assert(ecs._TYPEDOUBLE),
	userdata = assert(ecs._TYPEUSERDATA),
}
local typesize = {
	[typeid.int] = 4,
	[typeid.float] = 4,
	[typeid.bool] = 1,
	[typeid.int64] = 8,
	[typeid.dword] = 4,
	[typeid.word] = 2,
	[typeid.byte] = 1,
	[typeid.double] = 8,
	[typeid.userdata] = 8,
}

local M = ecs._METHODS

do	-- newtype
	local function parse(s)
		-- s is "name:typename"
		local name, typename = s:match "^([%w_]+):(%w+)$"
		local typeid = assert(typeid[typename])
		return { typeid, name }
	end

	local function align(c, field)
		local t = field[1]
		local tsize = typesize[t]
		local offset = ((c.size + tsize - 1) & ~(tsize-1))
		c.size = offset + tsize
		field[3] = offset
		return field
	end

	local function align_struct(c, t)
		if t then
			local s = typesize[t] - 1
			c.size = ((c.size + s) & ~s)
		end
	end

	function M:register(typeclass)
		local name = assert(typeclass.name)
		local ctx = context[self]
		ctx.all = nil	-- clear all pattern
		local typenames = ctx.typenames
		local id = ctx.id + 1
		assert(typenames[name] == nil and id <= ecs._MAXTYPE)
		ctx.id = id
		local c = {
			id = id,
			name = name,
			size = 0,
		}
		for i, v in ipairs(typeclass) do
			c[i] = align(c, parse(v))
		end
		local ttype = typeclass.type
		if ttype == "lua" then
			assert(c.size == 0)
			c.size = ecs._LUAOBJECT
			assert(c[1] == nil)
		elseif c.size > 0 then
			align_struct(c, c[1][1])
		else
			-- size == 0, one value
			if ttype then
				local t = assert(typeid[typeclass.type])
				c.type = t
				c.size = typesize[t]
				c[1] = { t, "v", 0 }
			elseif typeclass.order then
				c.size = ecs._ORDERKEY
				c.tag = "ORDER"
			else
				c.tag = true
			end
		end
		typenames[name] = c
		self:_newtype(id, c.size)
		if typeclass.ref then
			c.ref = true
			self:register { name = name .. "_dead" }
		end
	end
end

local function dump(obj)
	for e,v in pairs(obj) do
		if type(v) == "table" then
			for k,v in pairs(v) do
				print(e,k,v)
			end
		else
			print(e,v)
		end
	end
end

function M:new(obj)
--	dump(obj)
	local eid = self:_newentity()
	local typenames = context[self].typenames
	local reference = obj.reference
	if reference then
		obj.reference = nil
	end
	for k,v in pairs(obj) do
		local tc = typenames[k]
		if not tc then
			error ("Invalid key : ".. k)
		end
		local id = self:_addcomponent(eid, tc.id)
		if tc.tag ~= "ORDER" then
			self:object(k, id, v)
		end
	end
	if reference then
		local id = self:_addcomponent(eid, REFERENCE_ID)
		reference[1] = id
		reference[2] = REFERENCE_ID
		self:object("reference", id, reference)
		obj.reference = reference
		return reference
	end
end

function M:ref(name, refobj)
	local obj = assert(refobj[name])
	local ctx = context[self]
	local typenames = ctx.typenames
	local tc = assert(typenames[name])
	local refid = self:_reuse(tc.id)
	refobj[2] = tc.id
	if refid then
		local p = context[self].select[name .. ":out"]
		refobj[1] = refid
		self:_sync(p, refobj)
	else
		local eid = self:_newentity()
		refid = self:_addcomponent(eid, tc.id)
		refobj[1] = refid
		self:object(name, refid, obj)
	end
	for k,v in pairs(refobj) do
		if (v == true or v == false) and name ~= k then
			local p = context[self].select[k .. "?out"]
			self:_sync(p, refobj)
		end
	end
	return refid
end

function M:object_ref(name, refid)
	local typenames = context[self].typenames
	return { refid, typenames[name].id }
end

function M:release(name, refid)
	local id = assert(context[self].typenames[name].id)
	self:_release(id, refid)
end

function M:context(t)
	local typenames = context[self].typenames
	local id = {}
	for i, name in ipairs(t) do
		local tc = typenames[name]
		if not tc then
			error ("Invalid component name " .. name)
		end
		id[i] = tc.id
	end
	return self:_context(id)
end

function M:select(pat)
	return context[self].select[pat]()
end

function M:sync(pat, iter)
	local p = context[self].select[pat]
	self:_sync(p, iter)
	return iter
end

function M:readall(iter)
	local p = context[self].all
	self:_sync(p, iter)
	return iter
end

function M:clear(name)
	local id = assert(context[self].typenames[name].id)
	self:_clear(id)
end

function M:dumpid(name)
	local typenames = context[self].typenames
	return self:_dumpid(typenames[name].id)
end

function M:update()
	self:_update_reference(REFERENCE_ID)
	self:_update()
end

function M:remove_reference(ref)
	ref.reference = false
	self:sync("reference:out", ref)
	ref[1] = nil
end

do
	local _object = M._object
	function M:object(name, refid, v)
		local pat = context[self].ref[name]
		return _object(pat, v, refid)
	end

	function M:singleton(name, pattern, iter)
		local typenames = context[self].typenames
		if iter == nil then
			iter = { 1, typenames[name].id }
			if pattern then
				local p = context[self].select[pattern]
				return self:_read(p, iter)
			else
				return iter
			end
		else
			iter[1] = 1
			iter[2] = typenames[name].id
			local p = context[self].select[pattern]
			self:_sync(p, iter)
		end
		return iter
	end
end

function ecs.world()
	local w = ecs._world()
	context[w].typenames.REMOVED = {
		name = "REMOVED",
		id = ecs._REMOVED,
		size = 0,
		tag = true,
	}
	w:register {
		name = "reference",
		type = "lua",
	}
	assert(context[w].typenames.reference.id == REFERENCE_ID)
	return w
end

return ecs
