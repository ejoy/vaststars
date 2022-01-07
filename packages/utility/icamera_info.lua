local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local icamera = ecs.import.interface "ant.camera|icamera"
local icamera_info = ecs.interface "icamera_info"

function icamera_info.info(e, dir)
    w:sync("scene:in", e)
    local rc = e.scene
    local srt = rc.srt
    if rc.updir then
        local _srt = math3d.inverse(math3d.lookto(srt.t, dir, rc.updir))
        local s, r, t = math3d.srt(_srt)
        srt = {s = s, r = r, t = t}
    else
        srt.r.q = math3d.torotation(dir)
    end

    --
    local t = math3d.tovalue(math3d.quat2euler(srt.r))
    for k, v in pairs(t) do
        t[k] = math.deg(v)
    end

    print("camera scale", table.concat(math3d.tovalue(srt.s), ","))
    print("camera rotation", table.concat(t, ","))
    print("camera translation", table.concat(math3d.tovalue(srt.t), ","))

    local frustum = icamera.get_frustum(e)
    print("camera frustum")
    for k, v in pairs(frustum) do
        print(k, v)
    end
end