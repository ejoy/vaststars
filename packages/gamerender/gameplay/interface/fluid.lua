local iprototype = require "gameplay.interface.prototype"
local gameplay = import_package "vaststars.gameplay"
local ifluidbox = gameplay.interface "fluidbox"
local ALL_DIR <const> = require("gameplay.interface.constant").ALL_DIR

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

do
    local PIPE_FLUIDBOXES_DIR = ALL_DIR

    local funcs = {}
    funcs["fluidbox"] = function(typeobject, x, y, dir, result, fluid_name)
        for _, conn in ipairs(typeobject.fluidbox.connections) do
            local dx, dy, dir = iprototype:rotate_fluidbox(conn.position, dir, typeobject.area)
            result[#result+1] = {x = x + dx, y = y + dy, dir = dir, fluid_name = fluid_name}
        end
        return result
    end

    local function get_fluidboxes_fluid_name(fluid_name, iotype, index)
        if not fluid_name[iotype] then
            return ""
        end
        return fluid_name[iotype][index] or ""
    end

    local iotypes <const> = {"input", "output"}
    funcs["fluidboxes"] = function(typeobject, x, y, dir, result, fluid_name)
        for _, iotype in ipairs(iotypes) do
            for _, v in ipairs(typeobject.fluidboxes[iotype]) do
                for index, conn in ipairs(v.connections) do
                    local dx, dy, dir = iprototype:rotate_fluidbox(conn.position, dir, typeobject.area)
                    result[#result+1] = {x = x + dx, y = y + dy, dir = dir, fluid_name = get_fluidboxes_fluid_name(fluid_name, iotype, index)}
                end
            end
        end
        return result
    end

    function M:get_fluidbox(prototype_name, x, y, dir, fluid_name)
        local result = {}
        local typeobject = assert(iprototype:queryByName("entity", prototype_name))
        if typeobject.pipe then
            for _, dir in ipairs(PIPE_FLUIDBOXES_DIR) do
                result[#result+1] = {x = x, y = y, dir = dir, fluid_name = fluid_name}
            end
        else
            local types = typeobject.type
            for i = 1, #types do
                local func = funcs[types[i]]
                if func then
                    result = func(typeobject, x, y, dir, result, fluid_name)
                end
            end
        end
        return result
    end
end

return M
