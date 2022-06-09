local iprototype = require "gameplay.interface.prototype"

local M = {}

function M:item_counts(world, e)
    local r = {}
    local typeobject = iprototype:queryById(e.entity.prototype)
    for i = 1, typeobject.slots do
        local c, n = world:container_get(e.chest.container, i)
        if c then
            r[c] = n
        end
    end
    return r
end

function M:pickup_place(world, e1, e2, prototype, count)
    if not world:container_pickup(e1.chest.container, prototype, count) then
        log.error(("failed to pickup `%s` `%s`"):format(prototype, count))
    else
        if not world:container_place(e2.chest.container, prototype, count) then
            log.error(("failed to place `%s` `%s`"):format(prototype, count))
        end
    end
end

return M