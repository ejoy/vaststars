local ecs = ...
local world = ecs.world
local w = world.w

local update_sys = ecs.system "update_system"
local q = {}

local gen_id; do
    local id = 0
    function gen_id()
        id = id + 1
        return id
    end
end

function update_sys:data_changed()
    for id, f in pairs(q) do
        if not f() then
            q[id] = nil
        end
    end
end

local iupdate = ecs.interface "iupdate"
function iupdate.add(f)
    q[gen_id()] = f
end
