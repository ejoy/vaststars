package.path = "/engine/?.lua"
require "bootstrap"

import_package "vaststars.prototype"

local gameplay = import_package "vaststars.gameplay"


local world = gameplay.createWorld()
local function dump_fluid()
    local ecs = world.ecs
    local function display(entity_id, fluid, id, fluidbox)
        if fluid ~= 0 then
            local r = world:fluidflow_query(fluid, id)
            if r then
                print(entity_id, gameplay.query(fluid).name, ("%0.2f/%d\t%0.2f"):format(r.volume / r.multiple, fluidbox.capacity, r.flow / r.multiple))
            end
        end
    end
    for v in world.ecs:select "fluidbox:in entity:in" do
        local pt = gameplay.query(v.entity.prototype)
        display(("fluidbox (%d %d)"):format(v.entity.x, v.entity.y), v.fluidbox.fluid, v.fluidbox.id, pt.fluidbox)
    end
    for v in world.ecs:select "fluidboxes:in entity:in" do
        local pt = gameplay.query(v.entity.prototype)
        for _, classify in ipairs {"in1","in2","in3","in4","out1","out2","out3"} do
            local fluid = v.fluidboxes[classify.."_fluid"]
            local id = v.fluidboxes[classify.."_id"]
            local what, i = classify:match "(%a*)(%d)"
            display(("fluidboxes (%d %d)"):format(v.entity.x, v.entity.y), fluid, id, pt.fluidboxes[what.."put"][tonumber(i)])
        end
    end
end

--------------------
world:create_entity "指挥中心" {
    dir = 'N',
    x = 0,
    y = 0,
}

world:create_entity "地下卤水挖掘机" {
    dir = "N",
    x = 128,
    y = 128,
    fluids = {
        output = {
            {'地下卤水', 0},
        }
    },
}

world:create_entity "管道1-I型" {
    x = 128,
    y = 129,
    dir = "N",
    fluid = {'地下卤水', 0},
}

world:build()

for i = 1, 2400 do
    world:update()

    for v in world.ecs:select "generator capacitance:out" do
        v.capacitance.shortage = 0
    end
end

for e in world.ecs:select "entity:in" do
    if 128 == e.entity.x and e.entity.y == 129 then
        world.ecs:remove(e)
        print("remove")
    end
end

world:create_entity "管道1-I型" {
    x = 128,
    y = 129,
    dir = "N",
    fluid = {'地下卤水', 0},
}
world:build()

for i = 1, 2400 do
    world:update()

    for v in world.ecs:select "generator capacitance:out" do
        v.capacitance.shortage = 0
    end
end

dump_fluid()
