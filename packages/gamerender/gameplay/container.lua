local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"

local M = {}

function M:get(container)
    local r = {}

    if container == 0xFFFF then
        return r
    end

    local i = 0
    while true do
        i = i + 1
        local c, n = gameplay_core.container_get(container, i)
        if c then
            local typeobject = assert(iprototype:query(c), ("can not found id `%s`"):format(c))
            r[typeobject.name] = n
        else
            break
        end
    end

    return r
end

return M