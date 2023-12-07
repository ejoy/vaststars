local timer = {}; timer.__index = timer

function timer:update()
	local t = self._tick
	local f = self[t]
	if f then
		f()
		self[t] = nil
	end
	self._tick = t + 1
end

function timer:add(tick, func)
	local t = self._tick + tick
	local f = self[t]
	self[t] = f and function()
		f()
		func()
	end or func
end

function timer:interval(tick, func)
	assert(tick > 0)
	local function f()
		func()
		self:add(tick, f)
	end
	self:add(tick, f)
end

function timer.new()
	local t = { _tick = 0 }
	return setmetatable(t, timer)
end

return timer
