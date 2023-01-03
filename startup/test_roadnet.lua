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

local function print_slot(prefix, chest, i)
    local slot = world:container_get(chest, i)
    print(string.format("%s itme(%s) amount(%s) limit(%s) lock_space(%s) type(%s)", prefix, slot.item, slot.amount, slot.limit, slot.lock_space, slot.type))
end

local function add_req(time, prototype_name, count)
    local prototype = gameplay.prototype.queryByName("item", prototype_name).id
    local ecs = world.ecs
    local e = assert(ecs:first("base entity:in chest:update"))
    local typeobject = gameplay.prototype.queryById(e.entity.prototype)
    for i = 1, typeobject.slots do
        local slot = world:container_get(e.chest, i)
        if slot then
            if slot.item == prototype then
                world:container_set(e.chest, i, {limit = slot.limit + count})
                return
            end
        end
    end

    local info = world:chest_slot {
        type = "blue",
        item = prototype_name,
        amount = 0,
        limit = count,
    }
    world:container_add(e.chest, info)
end

for i = 1, 20 do
    add_req(i, "铁矿石", 1)
    world:build()
end

local function dump_item()
    print("=============")
    local ecs = world.ecs
    for v in ecs:select "eid:in base:in chest:in entity:in" do
        for i = 1, 60 do
            local slot = world:container_get(v.chest, i)
            if slot then
                print(i, gameplay.prototype.queryById(slot.item).name, slot.amount, slot.limit, slot.lock_space, slot.type)
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
-- assert(movement)

print "ok"
