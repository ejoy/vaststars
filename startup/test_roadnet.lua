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

local function backup_restore(world)
    local fs = require "bee.filesystem"
    local archival_backup_dir = (fs.appdata_path() / "test/archiving"):string()
    if fs.exists(fs.path(archival_backup_dir)) then
        fs.remove_all(archival_backup_dir)
    end
    world:backup(archival_backup_dir)

    local newworld = gameplay.createWorld()
    newworld:restore(archival_backup_dir)
    newworld:build()

    return newworld
end

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

for i = 1, 10 do
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
                print_slot(i, v.chest, i)
            end
        end
    end
end

world:wait(20*50, function ()
    dump_item()
    world = backup_restore(world)
    dump_item()

    world:wait(1000*50, function ()
        dump_item()
        world.quit = true
    end)
end)

local movement = false
while not world.quit do
    world:update()

    for _ in world:roadnet_each_lorry() do
        movement = true
    end
end

dump_item()
assert(movement)

print "ok"
