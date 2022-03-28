local ecs = ...
local world = ecs.world
local w = world.w

local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local fs = require "filesystem"
local datalist  = require "datalist"
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local camera_prefab_path <const> = fs.path "/pkg/vaststars.resources/"

---
local engine = {}
function engine.set_camera_prefab(prefab_file_name)
    local f <close> = fs.open(camera_prefab_path .. prefab_file_name)
    if not f then
        log.error(("can nof found prefab `%s`"):format(prefab_file_name))
        return
    end

    local data = datalist.parse(f:read "a")[1].data
    if not data then
        log.error(("invalid data `%s`"):format(prefab_file_name))
        return
    end

    local mq = w:singleton("main_queue", "camera_ref:in")
    local camera_ref = mq.camera_ref
    local e = world:entity(camera_ref)

    local srt = data.scene.srt
    iom.set_srt(e, srt.s or mc.ONE, srt.r, srt.t)
    iom.set_view(e, iom.get_position(e), iom.get_direction(e), data.scene.updir)
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