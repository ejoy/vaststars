local fluid_list_cfg = import_package "vaststars.config".fluid_list
local iprototype = require "gameplay.prototype"

local get_fluid_category; do
    local t = {}
    for _, v in pairs(iprototype:all_prototype_name()) do
        if iprototype:has_type(v.type, "fluid") then
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