local general = require "gameplay.utility.general"
local prototype_api = require "gameplay.prototype"

local M = {}

local function get_items(s)
    local r = {}
    for idx = 1, #s // 4 do
        local id, n = string.unpack("<I2I2", s, 4 * idx - 3)
        local typeobject = assert(prototype_api.query(id), ("can not found id `%s`"):format(id))
        r[#r+1] = {id = id, name = typeobject.name, count = n, icon = typeobject.icon}
    end
    return r
end
M.get_items = get_items

do
    local t = {
        {"ingredients", "input"},
        {"results", "output"},
    }

    function M.get_fluids(typeobject)
        local fluids
        for _, v in ipairs(t) do
            local t = {}
            for _, v in ipairs(get_items(typeobject[v[1]])) do
                if general.is_fluid_id(v.id) then
                    t[#t+1] = v.name
                end
            end
            if #t > 0 then
                fluids = fluids or {}
                fluids[v[2]] = t
            end
        end

        if fluids and next(fluids) then
            for _, v in ipairs(t) do
                fluids[v[2]] = fluids[v[2]] or {}
            end
        end
        return fluids
    end
end

return M