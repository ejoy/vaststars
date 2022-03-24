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

local function pack(x, y)
    return x | (y<<8)
end

function m:set(eid, x, y, prototype_name)
    local typeobject = assert(gameplay.queryByName("entity", prototype_name))
    local types = typeobject.type
    for i = 1, #types do
        local func = funcs[types[i]]
        if func then
            for _, v in ipairs(func(x, y, typeobject)) do
                m.map[pack(v.x, v.y)] = eid
            end
        end
    end
end

function m:unset(eid)
    for coord, _eid in pairs(self.map) do
        if _eid == eid then
            self.map[coord] = nil
        end
    end
end

function m:check(x, y)
    local coord = pack(x, y)
    return (self.map[coord] ~= nil)
end

return m