local ecs = ...
local world = ecs.world
local w = world.w
local gameplay = import_package "vaststars.gameplay"
import_package "vaststars.prototype"

local prototype = {}
function prototype.get_area(prototype_name)
    local pt = gameplay.queryByName("entity", prototype_name)
    if not pt then
        log.error(("can not found entity `%s`"):format(prototype_name))
        return
    end
    return pt.area
end

return prototype