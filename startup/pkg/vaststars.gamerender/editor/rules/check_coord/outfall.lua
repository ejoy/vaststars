local ecs = ...
local world = ecs.world

local chimney = ecs.require "editor.rules.check_coord.chimney"

return function (x, y, dir, typeobject, exclude_object_id)
    local r, errmsg = chimney(x, y, dir, typeobject, exclude_object_id)
    if not r then
        if errmsg == "chimneys cannot emit liquids" then
            errmsg = "outfall cannot discharge gases"
        end
        return false, errmsg
    end
    return true
end