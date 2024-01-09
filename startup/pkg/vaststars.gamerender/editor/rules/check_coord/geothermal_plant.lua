local ecs = ...
local world = ecs.world

local mining = ecs.require "editor.rules.check_coord.mining"

return function (x, y, dir, typeobject, exclude_object_id)
    local r, errmsg = mining(x, y, dir, typeobject, exclude_object_id)
    if not r then
        if errmsg == "needs to be placed above a resource mine" then
            errmsg = "needs to be placed above geothermal"
        end
        return false, errmsg
    end
    return true
end