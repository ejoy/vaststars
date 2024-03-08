local ecs = ...
local world = ecs.world

local CONSTANT <const> = require "gameplay.interface.constant"
local ROTATORS <const> = CONSTANT.ROTATORS
local DIRECTION <const> = CONSTANT.DIRECTION
local ROAD_WIDTH_SIZE <const> = CONSTANT.ROAD_WIDTH_SIZE
local ROAD_HEIGHT_SIZE <const> = CONSTANT.ROAD_HEIGHT_SIZE
local WORLD_MOVE_DELTA <const> = {
    ['N'] = {x = 0,  y = 1},
    ['E'] = {x = 1,  y = 0},
    ['S'] = {x = 0,  y = -1},
    ['W'] = {x = -1, y = 0},
    [DIRECTION.N] = {x = 0,  y = 1},
    [DIRECTION.E] = {x = 1,  y = 0},
    [DIRECTION.S] = {x = 0,  y = -1},
    [DIRECTION.W] = {x = -1, y = 0},
}

local math3d = require "math3d"
local icoord = require "coord"
local iplayback = ecs.require "ant.animation|playback"
local iom = ecs.require "ant.objcontroller|obj_motion"
local iprototype = require "gameplay.interface.prototype"
local imessage = ecs.require "message_sub"

imessage:sub("road_next_indicator|on_position_change", function(instance, self, ...)
    local building_srt = ...
    local position = building_srt.t
    local delta = WORLD_MOVE_DELTA[self.forward_dir]
    local x, z = math3d.index(position, 1) + delta.x * ROAD_WIDTH_SIZE, math3d.index(position, 3) + delta.y * ROAD_HEIGHT_SIZE

    local root <close> = world:entity(instance.tag['*'][1])
    iom.set_position(root, math3d.vector(x, math3d.index(position, 2), z))
    iom.set_rotation(root, ROTATORS[iprototype.rotate_dir_times(self.forward_dir, -1)])
end)

local function create(dx, dy, typeobject, dir, forward_dir)
    local instance = world:create_instance {
        prefab = "/pkg/vaststars.resources/glbs/road/road_indicator.glb|mesh.prefab",
        on_ready = function (instance)
            local root <close> = world:entity(instance.tag['*'][1])
            iom.set_position(root, math3d.vector(icoord.position(dx, dy, iprototype.rotate_area(typeobject.area, dir))))
            iom.set_rotation(root, ROTATORS[iprototype.rotate_dir_times(forward_dir, -1)])

            for _, eid in ipairs(instance.tag["*"]) do
                local e <close> = world:entity(eid, "animation?in")
                if e.animation then
                    iplayback.set_play(e, "Armature.002Action", true)
                    iplayback.completion_loop(e, "Armature.002Action")
                end
            end
        end,
    }

    local m = {forward_dir = forward_dir}
    function m:remove()
        imessage:pub("remove", instance)
    end

    function m:on_position_change(...)
        imessage:pub("road_next_indicator|on_position_change", instance, m, ...)
    end

    function m:on_status_change()
        -- do nothing
    end

    function m:set_forward_dir(forward_dir)
        self.forward_dir = forward_dir
    end

    return m
end

return create