local iprototype = require "gameplay.interface.prototype"
local iworld = require "gameplay.interface.world"

local M = {}

function M:item_counts(world, e)
    local r = {}
    local typeobject = iprototype.queryById(e.entity.prototype)
    for i = 1, typeobject.slots do
        local c, n = iworld.chest_get(world, e.chest.id, i)
        if c then
            r[c] = (r[c] or 0) + n -- different slot may have same prototype
        end
    end
    return r
end

return M