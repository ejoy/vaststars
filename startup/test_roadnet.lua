package.path = "engine/?.lua"
require "bootstrap"

import_package "vaststars.prototype"

local gameplay = import_package "vaststars.gameplay"

local world = gameplay.createWorld()
assert(loadfile "/test_roadnet_map.lua")(world)
world:build()

local ecs = world.ecs
for v in ecs:select "eid:in entity:in capacitance?update" do
    if v.capacitance then
        v.capacitance.network = 1
    end
end

world:wait(2000*50, function ()
    world.quit = true
end)

local eids = {}; do
    for v in ecs:select "eid:in entity:in" do
        local typeobject = gameplay.prototype.queryById(v.entity.prototype)
        if typeobject.name == "科研中心I" then
            assert(not eids[v.eid])
            eids[v.eid] = true
        end
    end
end
assert(next(eids))

local function dump_item(eid)
    local ecs = world.ecs
    for v in ecs:select "eid:in chest:in entity:in" do
        if v.eid == eid then
            for i = 1, 10 do -- hardcode: recipe "铁板1"
                local c, n = world:container_get(v.chest, i)
                if c then
                    print(gameplay.prototype.queryById(c).name, n)
                end
            end
        end
    end
end

while not world.quit do
    local roadnet = world.roadnet
    roadnet:update()
    world:update()

    local is_cross, mc, x, y, z
    for lorry_id, rc, tick in roadnet:each_lorry() do
        is_cross = (rc & 0x8000 ~= 0) -- see also: push_road_coord() in c code
        mc = roadnet:map_coord(rc)
        x = (mc >>  0) & 0xFF
        y = (mc >>  8) & 0xFF
        z = (mc >> 16) & 0xFF
    end
    -- dump_item(eid)
end

for eid in pairs(eids) do
    dump_item(eid)
end

print "ok"
