local gameplay = import_package "vaststars.gameplay"
local assembling = gameplay.interface "assembling"

local M = {}

function M:set_direction(world, e, dir)
    return assembling.set_direction(world, e, dir)
end
return M