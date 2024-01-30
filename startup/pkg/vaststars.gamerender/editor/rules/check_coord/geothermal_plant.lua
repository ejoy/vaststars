local ecs = ...
local world = ecs.world

local miner = ecs.require "editor.rules.check_coord.miner"

return function (x, y, dir, typeobject, exclude_coords)
    local r, errmsg = miner(x, y, dir, typeobject, exclude_coords)
    if not r then
        if errmsg == "needs to be placed above a resource mine" then
            errmsg = "needs to be placed above geothermal"
        end
        return false, errmsg
    end
    return true
end