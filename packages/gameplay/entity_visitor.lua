
return function (ecs, c)
	local index = ecs:make_index(c)

	local proxy_mt = {}
	function proxy_mt:__index(name)
		return index(self.id, name)
	end
	function proxy_mt:__newindex(name, value)
		index(self.id, name, value)
	end

	local cached = {}
	local cached_mt = {}
	function cached_mt:__index(id)
		local v = index[id]
		if not v then
			return
		end
		local proxy = setmetatable({id=id}, proxy_mt)
		cached[id] = proxy
		return proxy
	end

	local visitor_mt = {}
	visitor_mt.__index = setmetatable(cached, cached_mt)
	function visitor_mt:__newindex(id, e)
		assert(e == nil, "Cannot modify entity")
		local v = index[id]
		if v then
			ecs:remove(v)
		end
		cached[id] = nil
	end
	local api = {}
	function api.readall(id)
		local v = index[id]
		if v then
			return ecs:readall(v)
		end
	end
	return setmetatable(api, visitor_mt)
end
