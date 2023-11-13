
local ecs = ...
local world = ecs.world
local w = world.w

local LINE_WIDTH <const> = 70
local COLOR <const> = {0.0, 1.0, 0.0, 0.4}
local MATERIAL <const> = "/pkg/vaststars.resources/materials/polylinelist.material"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local CONSTANT <const> = require "gameplay.interface.constant"
local ROAD_SIZE <const> = CONSTANT.ROAD_SIZE

local math3d = require "math3d"
local GRID_POSITION_OFFSET <const> = math3d.constant("v4", {0, 0.2, 0, 0.0})

local ipl = ecs.require "ant.polyline|polyline"
local iom = ecs.require "ant.objcontroller|obj_motion"
local icoord = require "coord"
local icamera_controller = ecs.require "engine.system.camera_controller"

local M = {}
function M.create(width, height, unit, srt, pos_offset, material, position_type)
	local hw = width * 0.5
	local hw_len = hw * unit

	local hh = height * 0.5
	local hh_len = hh * unit

	local vertices = {}

	local function add_vertex(t, x, y, z)
		t[#t+1] = {x, y, z}
	end

	local function add_line(t, x0, z0, x1, z1)
		add_vertex(t, x0, 0, z0)
		add_vertex(t, x1, 0, z1)
	end

	for i=0, width do
        local x = -hw_len + i * unit
	    add_line(vertices, x, -hh_len, x, hh_len)
	end

	for i=0, height do
        local y = -hh_len + i * unit
      	add_line(vertices, -hw_len, y, hw_len, y)
	end

	if pos_offset then
		srt.t = math3d.add(srt.t, pos_offset)
	end

	local eid = ipl.add_linelist(vertices, LINE_WIDTH, COLOR, material or MATERIAL, srt, RENDER_LAYER.GRID)
	local ready = false
	world:create_entity {
		policy = {},
		data = {
			on_ready = function ()
				ready = true
			end
		}
	}

	local outer_proxy = {
		remove = function()
			world:remove_entity(eid)
		end,
		on_position_change = function(_, srt)
			assert(position_type)
			local coord = icoord.align(icamera_controller.get_screen_world_position(position_type), ROAD_SIZE, ROAD_SIZE)
			if not coord then
				return
			end

			local _, originPosition = icoord.align(math3d.vector {10, 0, -10}, ROAD_SIZE, ROAD_SIZE)
			coord[1], coord[2] = coord[1] - (coord[1] % ROAD_SIZE), coord[2] - (coord[2] % ROAD_SIZE)
			local t = icoord.position(coord[1], coord[2], ROAD_SIZE, ROAD_SIZE)
			local p = math3d.live(math3d.add(math3d.sub(t, originPosition), GRID_POSITION_OFFSET))

			if ready then
				local e <close> = world:entity(eid)
				iom.set_position(e, p)
			end
		end,
		-- TODO: remove this function
		set_position = function(_, position)
			if ready then
				local e <close> = world:entity(eid)
				iom.set_position(e, math3d.live(position))
			end
		end,
		on_status_change = function(_)
			-- do nothing
		end
	}

	return outer_proxy
end
return M