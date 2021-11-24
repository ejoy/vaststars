local ecs = ...
local world = ecs.world
local w = world.w

local mathpkg = import_package "ant.math"
local irq = ecs.import.interface "ant.render|irenderqueue"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local iterrain = ecs.import.interface "vaststars|iterrain"

local math3d = require "math3d"
local mc = mathpkg.constant

local m = ecs.system 'init_system'
function m:init_world()
    local mq = w:singleton("main_queue", "camera_ref:in")
    local eyepos = math3d.vector(0, 8, -8)
    local camera_ref = mq.camera_ref
    iom.set_position(camera_ref, eyepos)
    local dir = math3d.normalize(math3d.sub(mc.ZERO_PT, eyepos))
    iom.set_direction(camera_ref, dir)

    ecs.create_instance "/res/light_directional.prefab"
    ecs.create_instance "/res/skybox.prefab"
    iterrain.create()
end
