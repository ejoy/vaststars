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
local camera_prefab_file_name

local function get_camera_prefab_data(prefab_file_name)
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

    return data
end

---
local engine = {}
function engine.init_camera_prefab(prefab_file_name)
    local data = get_camera_prefab_data(prefab_file_name)
    if not data then
        return
    end

    local mq = w:singleton("main_queue", "camera_ref:in")
    local camera_ref = mq.camera_ref
    local e = world:entity(camera_ref)

    iom.set_srt(e, data.scene.srt.s or mc.ONE, data.scene.srt.r, data.scene.srt.t)
    iom.set_view(e, iom.get_position(e), iom.get_direction(e), data.scene.updir)
    camera_prefab_file_name = prefab_file_name
end

function engine.set_camera_prefab(prefab_file_name)
    local sdata, ddata = get_camera_prefab_data(camera_prefab_file_name), get_camera_prefab_data(prefab_file_name)
    if not sdata or not ddata then
        return
    end

    local mq = w:singleton("main_queue", "camera_ref:in")
    local camera_ref = mq.camera_ref
    local e = world:entity(camera_ref)

    local delta = math3d.sub(iom.get_position(e), sdata.scene.srt.t)
    local position = math3d.tovalue(math3d.add(delta, ddata.scene.srt.t))

    iom.set_srt(e, ddata.scene.srt.s or mc.ONE, ddata.scene.srt.r, position)
    iom.set_view(e, iom.get_position(e), iom.get_direction(e), ddata.scene.updir)
    camera_prefab_file_name = prefab_file_name
end

function engine.world_select(pat)
    local f, t, v = w:select(pat .. " REMOVED:absent")
    return function(t, v)
        local e = f(t, v)
        if not e then
            return
        end
        w:sync("id?in", e)
        if not e.id then
            return e
        end
        return e, world:entity(e.id)
    end, t, v
end

function engine.world_singleton(name, pat)
    local e = w:singleton(name, pat .. " REMOVED:absent")
    if not e then
        return
    end
    w:sync("id:in", e)
    return world:entity(e.id)
end

function engine.new_component(e, c, v)
    w:sync(("%s:new"):format(c), e)
end

return engine