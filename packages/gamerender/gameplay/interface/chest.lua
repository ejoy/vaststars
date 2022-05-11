local iprototype = require "gameplay.interface.prototype"

local M = {}

function M:item_counts(world, e)
    local r = {}
    local typeobject = iprototype:query(e.entity.prototype)
    for i = 1, typeobject.slots do
        local c, n = world:container_get(e.chest.container, i)
        if c then
            r[c] = n
        end
    end
    return r
end

return M