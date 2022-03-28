local gameplay = import_package "vaststars.gameplay"
local fluid_list_cfg = import_package "vaststars.config".fluid_list

local get_fluid_category; do
    local function is_type(prototype, t)
        for _, v in ipairs(prototype.type) do
            if v == t then
                return true
            end
        end
        return false
    end

    local t = {}
    for _, v in pairs(gameplay.prototype_name) do
        if is_type(v, "fluid") then
            for _, c in ipairs(v.catagory) do
                t[c] = t[c] or {}
                t[c][#t[c]+1] = {id = v.id, name = v.name, icon = v.icon}
            end
        end
    end

    local r = {}
    for catagory, v in pairs(t) do
        r[#r+1] = {catagory = catagory, icon = fluid_list_cfg[catagory].icon, pos = fluid_list_cfg[catagory].pos, fluid = v}
        table.sort(v, function(a, b) return a.id < b.id end)
    end
    table.sort(r, function(a, b) return a.pos < b.pos end)

    -- = {{catagory = xxx, icon = xxx, fluid = {{id = xxx, name = xxx, icon = xxx}, ...} }, ...}
    function get_fluid_category()
        return r
    end
end

return get_fluid_category