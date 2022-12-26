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

local function get_base_chest(world)
    local ecs = world.ecs
    for v in ecs:select "base entity:in chest:in" do
        return v.chest
    end
end

local info = world:chest_slot {
    type = "blue",
    item = "铁矿石",
    amount = 1,
    limit = 100,
}

local c = assert(get_base_chest(world))
world:container_add(c, info)

local function dump_item()
    local ecs = world.ecs
    for v in ecs:select "eid:in base:in chest:in entity:in" do
        for i = 1, 10 do
            local slot = world:container_get(v.chest, i)
            if slot then
                print(gameplay.prototype.queryById(slot.item).name, slot.amount)
            end
        end
    end
end

local movement = false
local roadnet = world.roadnet
while not world.quit do
    roadnet:update()
    world:update()

    for _ in roadnet:each_lorry() do
        movement = true
    end
end

dump_item()
assert(movement)

print "ok"
