return function (ecs)
	local proxy_mt = {}
	function proxy_mt:__index(name)
		local id = self.id
		local t = ecs:access(id, name)
		if type(t) ~= "table" then
			return t
		end
		local mt = {}
		mt.__index = t
		function mt:__newindex(k, v)
			if t[k] ~= v then
				t[k] = v
				ecs:access(id, name, t)
			end
		end
		return setmetatable({}, mt)
	end
	function proxy_mt:__newindex(name, value)
		ecs:access(self.id, name, value)
	end

	local entity = {}
	local entity_mt = {}
	function entity_mt:__index(id)
		if not ecs:exist(id) then
			return
		end
		local proxy = setmetatable({id=id}, proxy_mt)
		entity[id] = proxy
		return proxy
	end
	return setmetatable(entity, entity_mt)
end
