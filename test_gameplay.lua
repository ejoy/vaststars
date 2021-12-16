package.path = "engine/?.lua"
require "bootstrap"

import_package "vaststars.prototype"

local gameplay = import_package "vaststars.gameplay"
local system = gameplay.system
local test = system "test"
function test.update(world)
    for v in world:select "generator capacitance:update entity:in" do
        --v.capacitance = 0
    end
end

local game = gameplay.createWorld()
assert(loadfile "test_map.lua")(game)
game.rebuild()

local function dump()
    local world = game.world
    local container = require "vaststars.container.core"
    for v in world:select "chest:in debug:in" do
        local c, n = container.at(game.cworld, v.chest, 1)
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
