local ecs = ...
local world = ecs.world
local w = world.w

local gameplay = import_package "vaststars.gameplay"
import_package "vaststars.prototype"

local funcs = {}
funcs["fluidbox"] = function(typeobject)
    return #typeobject.fluidbox.connections > 0
end

local iotypes <const> = {"input", "output"}
funcs["fluidboxes"] = function(typeobject)
    for _, iotype in ipairs(iotypes) do
        for _, v in ipairs(typeobject.fluidboxes[iotype]) do
            if #v.connections > 0 then
                return true
            end
        end
    end
    return false
end

local function has_fluidboxes(prototype_name)
    local typeobject = gameplay.queryByName("entity", prototype_name)
    if typeobject.pipe then -- 管道直接认为有四个方向的流体口, 不读取配置
        return true
    else
        local types = typeobject.type
        for i = 1, #types do
            local func = funcs[types[i]]
            if func then
                if func(typeobject) then
                    return true
                end
            end
        end
        return false
    end
end
return has_fluidboxes