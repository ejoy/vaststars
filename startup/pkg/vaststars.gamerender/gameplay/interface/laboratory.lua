local iprototype = require "gameplay.interface.prototype"

local M = {}

local function get_elements(s)
    local r = {}
    for idx = 2, #s // 2 do
        local id = string.unpack("<I2", s, 2 * idx - 1)
        local typeobject = iprototype.queryById(id) or error(("can not found id `%s`"):format(id))
        r[#r+1] = {id = id, name = typeobject.name, icon = typeobject.item_icon, tech_icon = typeobject.tech_icon, stack = typeobject.stack}
    end
    return r
end

function M:get_elements(s)
    return get_elements(s)
end

return M