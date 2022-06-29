return function (ecs, c)
	local visitor = ecs:make_index(c)

	local proxy_mt = {}
	function proxy_mt:__index(name)
		local id = self.id
		local t = visitor(id, name)
		if type(t) ~= "table" then
			return t
		end
		local mt = {}
		mt.__index = t
		function mt:__newindex(k, v)
			if t[k] ~= v then
				t[k] = v
				visitor(id, name, t)
			end
		end
		return setmetatable({}, mt)
	end
	function proxy_mt:__newindex(name, value)
		visitor(self.id, name, value)
	end

	local entity = {}
	local entity_mt = {}
	function entity_mt:__index(id)
		local v = visitor[id]
		if not v then
			return
		end
		local proxy = setmetatable({id=id}, proxy_mt)
		entity[id] = proxy
		return proxy
	end
	return setmetatable(entity, entity_mt), visitor
end
