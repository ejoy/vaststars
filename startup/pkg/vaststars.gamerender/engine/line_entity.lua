local ecs = ...
local world = ecs.world
local w = world.w

local ipl = ecs.import.interface "ant.render|ipolyline"
local M = {}
function M.create_lines(pt, linewidth, color, render_layer)
	return ipl.add_linelist(pt, linewidth, color, nil, nil, render_layer)
end
return M