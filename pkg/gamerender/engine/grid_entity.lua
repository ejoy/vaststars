
local ecs = ...
local world = ecs.world
local w = world.w

local ipl = ecs.import.interface "ant.render|ipolyline"
local ivs = ecs.import.interface "ant.scene|ivisible_state"
local COLOR <const> = {0.0, 1.0, 0.0, 0.4}
local LINE_WIDTH = 70

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

	local c <const> = 1
    local material = "/pkg/vaststars.resources/materials/polylinelist.material"

	local pids = {}
	pids[#pids+1] = ipl.add_linelist(p1, LINE_WIDTH, COLOR, material, srt)
	pids[#pids+1] = ipl.add_linelist(p2, LINE_WIDTH * 2, COLOR, material, srt)

	log.info("create grid entity")

	local outer_proxy = {
		pids = pids,
		show = function(self, b)
			for _, eid in ipairs(self.pids) do
				local e <close> = w:entity(eid)
				if not e then
					return
				end
                ivs.set_state(e, "main_view", b)
                ivs.set_state(e, "selectable", b)
			end
		end,
		remove = function(self)
			log.info("remove grid entity")
			for _, eid in ipairs(self.pids) do
				local e <close> = w:entity(eid)
				if not e then
					return
				end
				w:remove(eid)
			end
		end,
	}
	return outer_proxy
end
return M