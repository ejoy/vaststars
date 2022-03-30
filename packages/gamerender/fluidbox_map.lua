local ecs = ...
local world = ecs.world
local w = world.w

local gameplay = import_package "vaststars.gameplay"
import_package "vaststars.prototype"
local vector2 = ecs.require "vector2"

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
    for _, v in ipairs({"input", "output"}) do
        for _, conn in ipairs(typeobject.fluidboxes[v].connections) do
            r[#r+1] = {x = x + conn.position[1], y = y + conn.position[2]}
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

-- 确认建造
function m:set(eid, x, y, prototype_name)
    local typeobject = assert(gameplay.queryByName("entity", prototype_name))
    -- 如果是管道, 则认为前后左右四个方向都是流体盒
    if typeobject.pipe then
        self.patch[pack(x, y)] = eid
    else
        local types = typeobject.type
        for i = 1, #types do
            local func = funcs[types[i]]
            if func then
                for _, v in ipairs(func(x, y, typeobject)) do
                    self.patch[pack(v.x, v.y)] = eid
                end
            end
        end
    end
end

-- 施工
function m:flush()
    for coord, eid in pairs(m.patch) do
        self.map[coord] = eid
    end
    self.patch = {}
end

function m:clear()
    self.patch = {}
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