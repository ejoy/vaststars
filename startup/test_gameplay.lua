package.path = "engine/?.lua"
require "bootstrap"

import_package "vaststars.prototype"

local gameplay = import_package "vaststars.gameplay"

local world = gameplay.createWorld()

local manual = assert(loadfile "test_manual.lua")(world)
assert(loadfile "test_map.lua")(world)
world:build()

local function manual_chest()
    local chest = {}
    local ecs = world.ecs
    for v in ecs:select "manual chest:in" do
        local i = 1
        while true do
            local c, n = world:container_get(v.chest.container, i)
            if c then
                chest[gameplay.queryById(c).name] = n
            else
                break
            end
            i = i + 1
        end
        break
    end
    return chest
end

local function manual_update(input)
    local solver = manual.create()
    local output = manual.evaluate(solver, manual_chest(), world:manual_container(), input)
    world:manual(output)
end

manual_update {
    {"铁棒1", 5},
    {"铁棒1", 5},
    {"铁棒1", 5},
    {"铁棒1", 5},
}

--world:backup  "../../startup/.log/sav"
--world:restore  "../../startup/.log/sav"
--world:build()

local function dump_item()
    print "=================="
    local ecs = world.ecs
    for v in ecs:select "chest:in" do
        for i = 1, 10 do
            local c, n = world:container_get(v.chest.container, i)
            if c then
                print(gameplay.query(c).name, n)
            else
                break
            end
        end
    end
end

local function dump_fluid()
    local ecs = world.ecs
    local function display(fluid, id)
        if fluid ~= 0 and id ~= 0 then
            local r = world:fluidflow_query(fluid, id)
            if r then
                print(gameplay.prototype.queryById(fluid).name, ("%0.2f/%d\t%0.2f"):format(r.volume / r.multiple, r.capacity / r.multiple, r.flow / r.multiple))
            end
        end
    end
    for v in ecs:select "fluidbox:in" do
        display(v.fluidbox.fluid, v.fluidbox.id)
    end
    for v in ecs:select "fluidboxes:in" do
        for _, classify in ipairs {"in1","in2","in3","in4","out1","out2","out3"} do
            local fluid = v.fluidboxes[classify.."_fluid"]
            local id = v.fluidboxes[classify.."_id"]
            display(fluid, id)
        end
    end
    print "===================="
end

local function dump()
    --dump_item()
    dump_fluid()
end

world:wait( 10*50, dump)
world:wait( 60*50, dump)
world:wait(110*50, dump)
world:wait(160*50, dump)
world:wait(1060*50, dump)

world:wait(100*50, function ()
    local assembling = gameplay.interface "assembling"
    local ecs = world.ecs
    for v in ecs:select "assembling id:in" do
        local e = world.entity[v.id]
        local pt = gameplay.prototype.queryById(e.entity.prototype)
        assembling.set_recipe(world, e, pt, "地质科技包1")
    end
    world:build()
end)

--world:loop(1, function ()
--    world:fluidflow_dump(0x3c01)
--end)

world:wait(1600*50, function ()
    world.quit = true
end)

while not world.quit do
    world:update()
end

print "ok"
