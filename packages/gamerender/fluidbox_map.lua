local ecs = ...
local world = ecs.world
local w = world.w

local gameplay = import_package "vaststars.gameplay"
import_package "vaststars.prototype"

local funcs = {}
funcs["fluidbox"] = function(x, y, typeobject)
    local r = {}
    for _, conn in ipairs(typeobject.fluidbox.connections) do
        r[#r+1] = {x = x + conn.position[1], y = y + conn.position[2]}
    end
    return r
end

funcs["fluidboxes"] = function(x, y, typeobject)
    local r = {}
    for _, iotype in ipairs({"input", "output"}) do
        for _, v in ipairs(typeobject.fluidboxes[iotype]) do
            for _, conn in ipairs(v.connections) do
                r[#r+1] = {x = x + conn.position[1], y = y + conn.position[2]}
            end
        end
    end
    return r
end

--
local m = {}
m.map = {}
m.patch = {}

local function pack(x, y)
    return x | (y<<8)
end

function m:precheck(x, y, prototype_name)
    local r = {}
    local typeobject = assert(gameplay.queryByName("entity", prototype_name))
    local types = typeobject.type
    for i = 1, #types do
        local func = funcs[types[i]]
        if func then
            for _, v in ipairs(func(x, y, typeobject)) do
                r[#r + 1] = {v.x, v.y}
            end
        end
    end
    return r
end

-- 确认建造
function m:set(eid, x, y, prototype_name)
    local typeobject = assert(gameplay.queryByName("entity", prototype_name))
    -- 如果是管道, 则直接认为此坐标是流体盒, 不从配置里读取(eg. O 型管道)
    if typeobject.pipe then
        self.patch[pack(x, y)] = self.patch[pack(x, y)] or {}
        self.patch[pack(x, y)][#self.patch[pack(x, y)] + 1] = eid
    else
        local types = typeobject.type
        for i = 1, #types do
            local func = funcs[types[i]]
            if func then
                local coord
                for _, v in ipairs(func(x, y, typeobject)) do
                    coord = pack(v.x, v.y)
                    self.patch[coord] = self.patch[coord] or {}
                    self.patch[coord][#self.patch[coord] + 1] = eid
                end
            end
        end
    end
end

-- 施工
function m:flush()
    for coord, v in pairs(self.patch) do
        self.map[coord] = v[#v]
    end
    self.patch = {}
end

function m:clear()
    self.patch = {}

    for coord, v in pairs(self.patch) do
        if #v == 1 then
            self.patch[coord] = nil
        else
            v[#v] = nil
        end
    end
end

-- 拆除
function m:unset(eid)
    for coord, _eid in pairs(self.map) do
        if _eid == eid then
            self.map[coord] = nil
        end
    end
end

-- 检查某个坐标是否有流体盒
function m:check(x, y)
    local coord = pack(x, y)
    if self.patch[coord] then
        return true
    else
        return (self.map[coord] ~= nil)
    end
end

return m