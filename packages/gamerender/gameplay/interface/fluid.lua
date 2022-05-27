local iprototype = require "gameplay.interface.prototype"
local gameplay = import_package "vaststars.gameplay"
local ifluidbox = gameplay.interface "fluidbox"

local M = {}

do
    local classify_to_iotype <const> = {
        ["input"] = "in",
        ["output"] = "out",
    }

    local iotype_to_classity = {}
    for k, v in pairs(classify_to_iotype) do
        iotype_to_classity[v] = k
    end

    -- input -> in
    function M:classify_to_iotype(s)
        return classify_to_iotype[s]
    end

    -- in -> input
    function M:iotype_to_classity(s)
        return iotype_to_classity[s]
    end
end

function M:need_set_fluid(prototype_name)
    local typeobject = iprototype:queryByName("entity", prototype_name)
    if not iprototype:has_type(typeobject.type, "fluidbox") then
        return false
    end
    return #typeobject.fluidbox.connections > 0
end

function M:update_fluidbox(e, fluid_name)
    local typeobject = iprototype:queryByName("fluid", fluid_name)
    if not typeobject then
        ifluidbox.update_fluidbox(e, 0)
    else
        ifluidbox.update_fluidbox(e, typeobject.id)
    end
end

return M
