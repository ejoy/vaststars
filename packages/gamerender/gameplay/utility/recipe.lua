local gameplay = import_package "vaststars.gameplay"
local M = {}

function M.get_items(s)
    local r = {}
    for idx = 1, #s // 4 do
        local id, n = string.unpack("<I2I2", s, 4 * idx - 3)
        local typeobject = assert(gameplay.query(id), ("can not found id `%s`"):format(id))
        r[#r+1] = {id = id, name = typeobject.name, count = n, icon = typeobject.icon}
    end
    return r
end

return M