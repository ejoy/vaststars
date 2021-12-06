local ecs = ...
local world = ecs.world

local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local prefab_cfgs = require "lualib.config.prefab"
local math3d = require "math3d"

local function get_srt(prefab_file_name)
    local prefab_cfg = prefab_cfgs[prefab_file_name]
    if not prefab_cfg then
        return {}
    end

    local srt = {}
    if prefab_cfg.scale then
        srt.s = math3d.vector({prefab_cfg.scale, prefab_cfg.scale, prefab_cfg.scale})
    end

    if prefab_cfg.direction then
        srt.r = math3d.torotation(math3d.normalize(math3d.vector(prefab_cfg.direction)))
    end

    if prefab_cfg.position then
        srt.t = prefab_cfg.position
    end

    return srt
end
return get_srt