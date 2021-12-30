package.path = "engine/?.lua"
require "bootstrap"

import_package "vaststars.prototype"

local gameplay = import_package "vaststars.gameplay"

local test = gameplay.system "test"

function test.init(world)
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

    local function rotate(position, d)
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
        local x = position[1]
        local y = position[2]
        local dir = (PipeDirection[position[3]] + d) % 4
        if d == N then
            return x, y, dir
        elseif d == E then
            return y, -x, dir
        elseif d == S then
            return -x, -y, dir
        elseif d == W then
            return -y, x, dir
        end
    end

    local function pipePostion(e, position)
        local x, y, dir = rotate(position, e.direction)
        return e.x + x + direction[dir][1], e.y + y + direction[dir][2]
    end

    local function fluid_list(s)
        local r = {}
        for i = 1, #s, 4 do
            local id = string.unpack("<I2I2", s, i)
            if id & 0x0C00 == 0x0C00 then
                r[#r+1] = id
            end
        end
        return r
    end
    local function init_fluidbox(fluidboxes, classify, max, s)
        local lst = fluid_list(s)
        assert(max >= #lst)
        for i = 1, #lst do
            fluidboxes[classify..i.."_fluid"] = lst[i]
        end
        for i = #lst + 1, max do
            fluidboxes[classify..i.."_fluid"] = 0
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
        local pt = gameplay.query(e.prototype).fluidboxes[classify.."put"]
        for i = 1, #pt do
            local fluid = fluidboxes[classify..i.."_fluid"]
            for _, pipe in ipairs(pt[i].connections) do
                local x, y = pipePostion(e, pipe.position)
                walk_pipe(fluid, x, y)
            end
        end
    end

    local function init()
        for v in ecs:select "assembling:in fluidboxes:update" do
            local recipe = gameplay.query(v.assembling.recipe)
            init_fluidbox(v.fluidboxes, "in",  4, recipe.ingredients)
            init_fluidbox(v.fluidboxes, "out", 4, recipe.results)
        end
        for v in ecs:select "fluidbox:in entity:in" do
            local e = v.entity
            local pt = gameplay.query(e.prototype)
            local fluidbox = pt.fluidbox
            local connections = {}
            for _, conn in ipairs(fluidbox.connections) do
                connections[#connections+1] = {pipePostion(e, conn.position)}
            end
            local w, h = pt.area & 0xFF, pt.area >> 8
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
            assert(p.fluid ~= 0)
            v.fluidbox.fluid = p.fluid
            v.fluidbox.id = 0
        end
    end

    init()
    walk()
    sync()
end

function test.update(world)
    for v in world.ecs:select "generator capacitance:out" do
        v.capacitance.shortage = 0
    end
end

local world = gameplay.createWorld()
assert(loadfile "test_map.lua")(world)
--local sav = game.backup()
--local f = io.open("../../test.map", "w")
--f:write(sav)
--f:close()
--game.restore(sav)
world:build()

local function dump()
    local ecs = world.ecs
    --for v in ecs:select "chest:in" do
    --    for i = 1, 10 do
    --        local c, n = world:container_at(v.chest.container, i)
    --        if c then
    --            print(gameplay.query(c).name, n)
    --        else
    --            break
    --        end
    --    end
    --end
    local function display(fluid, id)
        if fluid ~= 0 then
            local r = world:fluidflow_query(fluid, id)
            if r then
                print(gameplay.query(fluid).name, ("%f/%f"):format(r.volume, r.volume + r.space))
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

world:wait(1*60*50, dump)
world:wait(3*60*50, dump)
world:wait(5*60*50, dump)

world:wait(10*60*50, function ()
    world.quit = true
end)

while not world.quit do
    world:update()
end

print "ok"
