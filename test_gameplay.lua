package.path = "engine/?.lua"
require "bootstrap"

import_package "vaststars.prototype"

local gameplay = import_package "vaststars.gameplay"

local test = gameplay.system "test"

function test.init(world)
    local ecs = world.ecs
    local Map = {}
    local direction <const> = {
        {0,-1}, --N
        {1,0}, --E
        {0,1}, --S
        {-1,0}, --W
        N = {0,-1},
        E = {1,0},
        S = {0,1},
        W = {-1,0},
    }

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
                    for i = 1, 4 do
                        if p.type & (1 << (i-1)) ~= 0 then
                            push(x + direction[i][1], y + direction[i][2])
                        end
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
            for _, pipe in ipairs(pt[i].pipe) do
                local dir = pipe.position[3]
                local x = e.x + pipe.position[1] + direction[dir][1]
                local y = e.y + pipe.position[2] + direction[dir][2]
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
        for v in ecs:select "pipe:in entity:in" do
            Map[(v.entity.x << 8)|v.entity.y] = {
                type = v.pipe.type
            }
        end
    end
    local function walk()
        for v in ecs:select "fluidboxes:in entity:in" do
            walk_fluidbox(v.fluidboxes, "in", v.entity)
            walk_fluidbox(v.fluidboxes, "out", v.entity)
        end
    end
    local function sync()
        for v in ecs:select "pipe fluidbox:out entity:in" do
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
    for v in ecs:select "chest:in description:in" do
        for i = 1, 10 do
            local c, n = world:container_at(v.chest.container, i)
            if c then
                print(gameplay.query(c).name, n)
            else
                break
            end
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
