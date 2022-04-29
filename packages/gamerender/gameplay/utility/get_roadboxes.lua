local prototype_api = require "gameplay.prototype"

local ROAD_DIR <const> = {'N', 'E', 'S', 'W'}
local function get_fluidboxes(prototype_name, x, y, dir)
    local r = {}
    local typeobject = prototype_api.queryByName("entity", prototype_name)
    if typeobject.road then -- 管道直接认为有四个方向的流体口, 不读取配置
        local dir = {}
        for _, d in ipairs(ROAD_DIR) do
            dir[d] = true
        end
        r[#r+1] = {x = x, y = y, road_dir = dir}
    end
    return r
end
return get_fluidboxes