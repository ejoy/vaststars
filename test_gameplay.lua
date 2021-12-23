package.path = "engine/?.lua"
require "bootstrap"

import_package "vaststars.prototype"

local gameplay = import_package "vaststars.gameplay"

local test = gameplay.system "test"

function test.update(world)
    for v in world:select "generator capacitance:out" do
        v.capacitance.shortage = 0
    end
end

local game = gameplay.createWorld()
assert(loadfile "test_map.lua")(game)
--local sav = game.backup()
--local f = io.open("../../test.map", "w")
--f:write(sav)
--f:close()
--game.restore(sav)
game.rebuild()

local function dump()
    local world = game.world
    local container = require "vaststars.container.core"
    for v in world:select "chest:in description:in" do
        for i = 1, 10 do
            local c, n = container.at(game.cworld, v.chest.container, i)
            if c then
                print(gameplay.query(c).name, n)
            else
                break
            end
        end
    end
    print "===================="
end

game.wait(2*50, dump)
game.wait(4*50, dump)
game.wait(6*50, dump)
game.wait(300*50, dump)
game.wait(30*60*50, dump)

game.wait(600*50, function ()
    game.quit = true
end)

while not game.quit do
    game.update()
end

print "ok"
