return function (ecs, c)
	local index = ecs:make_index(c)

	local proxy_mt = {}
	function proxy_mt:__index(name)
		local id = self.id
		local t = index(id, name)
		if type(t) ~= "table" then
			return t
		end
		local mt = {}
		mt.__index = t
		function mt:__newindex(k, v)
			if t[k] ~= v then
				t[k] = v
				index(id, name, t)
			end
		end
		return setmetatable({}, mt)
	end
	function proxy_mt:__newindex(name, value)
		index(self.id, name, value)
	end

	local entity = {}
	local entity_mt = {}
	function entity_mt:__index(id)
		local v = index[id]
		if not v then
			return
		end
		local proxy = setmetatable({id=id}, proxy_mt)
		entity[id] = proxy
		return proxy
	end

	function entity_mt:__newindex(id, value)
		assert(value == nil, "Cannot modify entity")
		local v = index[id]
		if v then
			ecs:remove(v)
		end
	end

	function entity.readall(id)
		local v = index[id]
		if v then
			return ecs:readall(v)
		end
	end

	return setmetatable(entity, entity_mt)
end
