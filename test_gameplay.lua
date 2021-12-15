package.path = "engine/?.lua"
require "bootstrap"

local gameplay = import_package "vaststars.gameplay"
local game = gameplay.game
local system = gameplay.system
local csystem = gameplay.csystem

import_package "vaststars.prototype"

csystem "vaststars.powergrid.system"
csystem "vaststars.burner.system"
csystem "vaststars.assembling.system"
csystem "vaststars.inserter.system"

local test = system "test"
function test:update(world)
    for v in world:select "generator capacitance:update entity:in" do
        v.capacitance = 0
    end
end

game.init()
dofile "test_map.lua"
game.rebuild()

local function dump()
    local w = game.w
    local container = require "vaststars.container.core"
    for v in w:select "chest:in debug:in" do
        local c, n = container.at(game.world, v.chest, 1)
        print(v.debug.description, n)
    end
    print "===================="
end

game.wait(2*50, dump)
game.wait(4*50, dump)
game.wait(6*50, dump)
game.wait(300*50, dump)
game.wait(350*50, dump)

game.wait(600*50, function ()
    game.quit = true
end)

while not game.quit do
    game.update()
end

print "ok"
