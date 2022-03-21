local ecs = ...
local world = ecs.world
local w = world.w

local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local fs = require "filesystem"
local datalist  = require "datalist"
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local math3d = require "math3d"
local camera_prefab_path <const> = fs.path "/pkg/vaststars.resources/"

local function to_quat(t)
    for k, v in ipairs(t) do
        t[k] = math.rad(v)
    end
    return math3d.tovalue(math3d.quaternion(t))
end

local function get_camera_srt(prefab_file_name)
    local f<close> = fs.open(camera_prefab_path .. prefab_file_name)
    if f then
        local srt = datalist.parse(f:read "a")[1].data.scene.srt
        return srt.s or mc.ONE, srt.r, srt.t
    end
    return mc.ONE, to_quat({45.0, 0, 0}), {0, 60, -60}
end

---
local engine = {}
function engine.set_camera(prefab_file_name)
    local mq = w:singleton("main_queue", "camera_ref:in")
    local camera_ref = mq.camera_ref
    iom.set_srt(world:entity(camera_ref), get_camera_srt(prefab_file_name))
end

function engine.world_select(pat)
    local f, t, v = w:select(pat)
    return function(t, v)
        local e = f(t, v)
        if not e then
            return
        end
        w:sync("id:in", e)
        return e, world:entity(e.id)
    end, t, v
end

function engine.world_singleton(name, pat)
    local e = w:singleton(name, pat)
    if not e then
        return
    end
    w:sync("id:in", e)
    return world:entity(e.id)
end

return engine