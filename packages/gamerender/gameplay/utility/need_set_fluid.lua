local iprototype = require "gameplay.interface.prototype"

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

local function need_set_fluid(prototype_name)
    local typeobject = iprototype:queryByName("entity", prototype_name)
    if typeobject.pipe then -- 管道直接认为有四个方向的流体口, 不读取配置
        return true
    else
        local types = typeobject.type
        if iprototype:has_type(types, "assembling") then -- 组装机建造时不需要手动设置流体类型, 根据组装机的配方决定流体类型
            return false
        end

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
return need_set_fluid