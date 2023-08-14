
local ecs = ...
local world = ecs.world
local w = world.w

local ipl = ecs.require "ant.render|polyline.polyline"
local ivs = ecs.require "ant.render|visible_state"
local iom = ecs.require "ant.objcontroller|obj_motion"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local COLOR <const> = {0.0, 1.0, 0.0, 0.4}
local LINE_WIDTH = 70

local events = {}
events["show"] = function(_, e, b)
	ivs.set_state(e, "main_view", b)
	ivs.set_state(e, "selectable", b)
end
events["remove"] = function(_, e)
	w:remove(e)
end
events["obj_motion"] = function(_, e, method, ...)
    iom[method](e, ...)
end

local M = {}
function M.create(name, width, height, unit, srt)
	local hw = width * 0.5
	local hw_len = hw * unit

	local hh = height * 0.5
	local hh_len = hh * unit

	local p1 = {}
	local p2 = {}

	local function add_vertex(t, x, y, z)
		t[#t+1] = {x, y, z}
	end

	local function add_line(t, x0, z0, x1, z1)
		add_vertex(t, x0, 0, z0)
		add_vertex(t, x1, 0, z1)
	end

	for i=0, width do
        local x = -hw_len + i * unit
		if i % 4 == 0 then
	        add_line(p2, x, -hh_len, x, hh_len)
		else
			add_line(p1, x, -hh_len, x, hh_len)
		end
	end

	for i=0, height do
        local y = -hh_len + i * unit
		if i % 4 == 0 then
	        add_line(p2, -hw_len, y, hw_len, y)
		else
        	add_line(p1, -hw_len, y, hw_len, y)
		end
	end

    local material = "/pkg/vaststars.resources/materials/polylinelist.material"

	local objects = {}
	objects[#objects+1] = ientity_object.create(ipl.add_linelist(p1, LINE_WIDTH, COLOR, material, srt), events)
	objects[#objects+1] = ientity_object.create(ipl.add_linelist(p2, LINE_WIDTH, COLOR, material, srt), events)

	local outer_proxy = {
		objects = objects,
		show = function(self, b)
			for _, obj in ipairs(self.objects) do
				obj:send("show", b)
			end
		end,
		remove = function(self)
			assert(#self.objects > 0)
			for _, obj in ipairs(self.objects) do
				obj:send("remove")
			end
			self.objects = {}
		end,
		send = function (self, ...)
			for _, obj in ipairs(self.objects) do
				obj:send(...)
			end
		end,
	}
	return outer_proxy
end
return M