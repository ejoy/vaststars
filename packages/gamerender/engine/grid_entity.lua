
local ecs = ...
local world = ecs.world
local w = world.w

local ipl = ecs.import.interface "ant.render|ipolyline"

local M = {}
function M.create(name, width, height, unit, linewidth, srt)
	local hw = width * 0.5
	local hw_len = hw * unit

	local hh = height * 0.5
	local hh_len = hh * unit

	local pl = {}
	local function add_vertex(x, y, z)
		pl[#pl+1] = {x, y, z}
	end

	local function add_line(x0, z0, x1, z1)
		add_vertex(x0, 0, z0)
		add_vertex(x1, 0, z1)
	end

	for i=0, width do
        local x = -hw_len + i * unit
        add_line(x, -hh_len, x, hh_len)
	end

	for i=0, height do
        local y = -hh_len + i * unit
        add_line(-hw_len, y, hw_len, y)
	end

	local c <const> = 1
    local material = "/pkg/ant.resources/materials/polylinelist.material"
	return ipl.add_linelist(pl, linewidth, {0.0, c, 0.0, 0.5}, material, srt)
end
return M