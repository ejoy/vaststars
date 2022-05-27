local iprototype = require "gameplay.interface.prototype"
local PIPE_FLUIDBOXES_DIR <const> = {'N', 'E', 'S', 'W'}
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

do
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

    function M:need_set_fluid(prototype_name)
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

    function M:has_fluidbox(prototype_name)
        local typeobject = iprototype:queryByName("entity", prototype_name)
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
end

do
    local funcs = {}
    funcs["fluidbox"] = function(typeobject, x, y, dir, fluid_name, result)
        for _, conn in ipairs(typeobject.fluidbox.connections) do
            local dx, dy, dir = iprototype:rotate_fluidbox(conn.position, dir, typeobject.area)
            result[iprototype:packcoord(x + dx, y + dy)] = {[dir] = fluid_name}
        end
        return result
    end

    local iotypes <const> = {"input", "output"}
    funcs["fluidboxes"] = function(typeobject, x, y, dir, fluid_name, result)
        for _, iotype in ipairs(iotypes) do
            for _, v in ipairs(typeobject.fluidboxes[iotype]) do
                for index, conn in ipairs(v.connections) do
                    if fluid_name and fluid_name[iotype] then
                        local dx, dy, dir = iprototype:rotate_fluidbox(conn.position, dir, typeobject.area)
                        local coord = iprototype:packcoord(x + dx, y + dy)
                        result[coord] = result[coord] or {}
                        result[coord][dir] = fluid_name[iotype][index] -- TODO
                    end
                end
            end
        end
        return result
    end

    -- = {[coord] = {[dir] = fluid_name, ...}, ...}
    function M:get_fluidbox_coord(prototype_name, x, y, dir, fluid_name)
        local r = {}
        local typeobject = assert(iprototype:queryByName("entity", prototype_name))
        if typeobject.pipe then -- 管道直接认为有四个方向的流体口, 不读取配置
            local dir = {}
            for _, d in ipairs(PIPE_FLUIDBOXES_DIR) do
                dir[d] = fluid_name
            end
            local coord = iprototype:packcoord(x, y)
            r[coord] = dir
        else
            local types = typeobject.type
            for i = 1, #types do
                local func = funcs[types[i]]
                if func then
                    r = func(typeobject, x, y, dir, fluid_name, r)
                end
            end
        end
        return r
    end
end

-- 获取建筑的所有流体类型
do
    local funcs = {}
    funcs["fluidbox"] = function(typeobject, result, fluid_name)
        if next(typeobject.fluidbox.connections) then
            result[#result+1] = fluid_name
        end
        return result
    end

    local iotypes <const> = {"input", "output"}
    funcs["fluidboxes"] = function(typeobject, result, fluid_name)
        for _, iotype in ipairs(iotypes) do
            for _, v in ipairs(typeobject.fluidboxes[iotype]) do
                for index in ipairs(v.connections) do
                    if fluid_name and fluid_name[iotype] then
                        result[#result+1] = fluid_name[iotype][index]
                    end
                end
            end
        end
        return result
    end

    function M:get_fluid_name(prototype_name, fluid_name)
        assert(fluid_name)

        local r = {}
        local typeobject = assert(iprototype:queryByName("entity", prototype_name))
        if typeobject.pipe then -- 管道直接认为有四个方向的流体口, 不读取配置
            r[#r+1] = fluid_name
        else
            local types = typeobject.type
            for i = 1, #types do
                local func = funcs[types[i]]
                if func then
                    func(typeobject, r, fluid_name)
                end
            end
        end
        return r
    end
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
