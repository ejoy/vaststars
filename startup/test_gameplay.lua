package.path = "engine/?.lua"
require "bootstrap"

import_package "vaststars.prototype"

local gameplay = import_package "vaststars.gameplay"
local assembling = gameplay.interface "assembling"

local function init(world)
    local ecs = world.ecs
    local Map = {}
    local direction <const> = {
        [0] = {0,-1}, --N
        {1,0}, --E
        {0,1}, --S
        {-1,0}, --W
        N = {0,-1},
        E = {1,0},
        S = {0,1},
        W = {-1,0},
    }
    local N <const> = 0
    local E <const> = 1
    local S <const> = 2
    local W <const> = 3
    local PipeDirection <const> = {
        ["N"] = 0,
        ["E"] = 1,
        ["S"] = 2,
        ["W"] = 3,
    }

    local function rotate(position, direction, area)
        local w, h = area >> 8, area & 0xFF
        local x, y = position[1], position[2]
        local dir = (PipeDirection[position[3]] + direction) % 4
        w = w - 1
        h = h - 1
        if direction == N then
            return x, y, dir
        elseif direction == E then
            return h - y, x, dir
        elseif direction == S then
            return w - x, h - y, dir
        elseif direction == W then
            return y, w - x, dir
        end
    end

    local function pipePostion(e, position, area)
        local x, y, dir = rotate(position, e.direction, area)
        return e.x + x + direction[dir][1], e.y + y + direction[dir][2]
    end

    local function init_fluidbox(assembling, fluidboxes, classify, max, s)
        local lst = assembling["fluidbox_"..classify]
        for i = 1, max do
            local index = (lst >> ((i-1)*4)) & 0x0F
            if index ~= 0 then
                local id = string.unpack("<I2", s, 4*(index-1)+1)
                fluidboxes[classify..i.."_fluid"] = id
            else
                fluidboxes[classify..i.."_fluid"] = 0
            end
        end
    end

    local function walk_pipe(fluid, start_x, start_y)
        local task = {}
        local function push(x, y)
            task[#task+1] = { x, y }
        end
        local function pop()
            local n = #task
            local t = task[n]
            task[n] = nil
            return t[1], t[2]
        end
        push(start_x, start_y)
        while #task > 0 do
            local x, y = pop()
            local p = Map[(x << 8)|y]
            if p ~= nil then
                if p.fluid == nil then
                    p.fluid = fluid
                    for _, conn in ipairs(p.connections) do
                        push(conn[1], conn[2])
                    end
                else
                    assert(p.fluid == fluid)
                end
            end
        end
    end

    local function walk_fluidbox(fluidboxes, classify, e)
        local pt = gameplay.query(e.prototype)
        for i, fluidbox in ipairs(pt.fluidboxes[classify.."put"]) do
            local fluid = fluidboxes[classify..i.."_fluid"]
            if fluid ~= 0 then
                for _, pipe in ipairs(fluidbox.connections) do
                    local x, y = pipePostion(e, pipe.position, pt.area)
                    walk_pipe(fluid, x, y)
                end
            end
        end
    end

    local function init()
        --for v in ecs:select "assembling:in fluidboxes:update" do
        --    local recipe = gameplay.query(v.assembling.recipe)
        --    init_fluidbox(v.assembling, v.fluidboxes, "in",  4, recipe.ingredients)
        --    init_fluidbox(v.assembling, v.fluidboxes, "out", 4, recipe.results)
        --end
        for v in ecs:select "fluidbox:in entity:in" do
            local e = v.entity
            local pt = gameplay.query(e.prototype)
            local fluidbox = pt.fluidbox
            local connections = {}
            for _, conn in ipairs(fluidbox.connections) do
                connections[#connections+1] = {pipePostion(e, conn.position, pt.area)}
            end
            local w, h = pt.area >> 8, pt.area & 0xFF
            if e.direction == E or e.direction == W then
                w, h = h, w
            end
            local entity = {
                connections = connections
            }
            for i = 0, w-1 do
                for j = 0, h-1 do
                    local x = e.x + i
                    local y = e.y + j
                    Map[(x << 8)|y] = entity
                end
            end
        end
    end
    local function walk()
        for v in ecs:select "fluidboxes:in entity:in" do
            walk_fluidbox(v.fluidboxes, "in", v.entity)
            walk_fluidbox(v.fluidboxes, "out", v.entity)
        end
    end
    local function sync()
        for v in ecs:select "fluidbox:out entity:in" do
            local p = Map[(v.entity.x << 8)|v.entity.y]
            assert(p.fluid ~= 0 and p.fluid ~= nil)
            v.fluidbox.fluid = p.fluid
            v.fluidbox.id = 0
        end
    end

    init()
    walk()
    sync()
end

local test = gameplay.system "test"

function test.update(world)
    for v in world.ecs:select "generator capacitance:out" do
        v.capacitance.shortage = 0
    end
end

local world = gameplay.createWorld()
assert(loadfile "test_map.lua")(world)

--world:backup  "../../startup/.log/sav"
--world:restore "../../startup/.log/sav"

for v in world.ecs:select "assembling:update fluidboxes:update entity:in" do
    if v.assembling.recipe == 0 then
        local pt = gameplay.query(v.entity.prototype)
        local fluids = {
            input = {
                "空气"
            },
            output = {
                "氮气",
                "二氧化碳",
            }
        }
        assembling.set_recipe(world, v, pt, "空气分离1", fluids)
    end
end

init(world)
world:build()


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
    local function display(fluid, id, fluidbox)
        if fluid ~= 0 then
            local r = world:fluidflow_query(fluid, id)
            if r then
                print(gameplay.query(fluid).name, ("%0.2f/%d\t%0.2f"):format(r.volume / r.multiple, fluidbox.capacity, r.flow / r.multiple))
            end
        end
    end
    for v in ecs:select "fluidbox:in entity:in" do
        local pt = gameplay.query(v.entity.prototype)
        display(v.fluidbox.fluid, v.fluidbox.id, pt.fluidbox)
    end
    for v in ecs:select "fluidboxes:in entity:in" do
        local pt = gameplay.query(v.entity.prototype)
        for _, classify in ipairs {"in1","in2","in3","in4","out1","out2","out3"} do
            local fluid = v.fluidboxes[classify.."_fluid"]
            local id = v.fluidboxes[classify.."_id"]
            local what, i = classify:match "(%a*)(%d)"
            display(fluid, id, pt.fluidboxes[what.."put"][tonumber(i)])
        end
    end
    print "===================="
end

local function dump()
    --dump_item()
    dump_fluid()
end

world:wait(2*50, dump)
world:wait(10*50, dump)
world:wait(20*50, dump)
world:wait(30*50, dump)

--world:loop(1, function ()
--    world:fluidflow_dump(0x3c01)
--end)

world:wait(10*60*50, function ()
    world.quit = true
end)

while not world.quit do
    world:update()
end

print "ok"
