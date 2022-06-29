local ecs   = ...
local world = ecs.world
local w     = world.w
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"

local mt_sys = ecs.system "mesh_terrain_system"
local math3d = require "math3d"
local mathpkg = import_package"ant.math"
local mc = mathpkg.constant

local rotators <const> = {
    math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(0)}),
    math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(90)}),
    math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(180)}),
    math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(270)}),
}

local function instance(pid, mp, pos, group_id)
    -- print(("terrain instance %s"):format(group_id))
    local g = ecs.group(group_id)
    local p = g:create_instance(mp)
    p.on_ready = function (e)
        iom.set_position(world:entity(e.root), pos)
        iom.set_rotation(world:entity(e.root), rotators[math.random(1, 4)])
        ecs.method.set_parent(e.root, pid)
    end
    world:create_object(p)
    return p
end

function mt_sys:entity_init()
    for e in w:select "INIT shape_terrain:in id:in" do
        local st = e.shape_terrain
        local ms = st.mesh_shape
        local terrainid = e.id
        local meshprefabs = ms.meshes

        for _, v in ipairs(ms) do
            local midx = v.mash_idx
            local group_id = v.group_id
            local pos = v.pos
            instance(terrainid, assert(meshprefabs[midx]), pos, group_id)
        end
    end
end
