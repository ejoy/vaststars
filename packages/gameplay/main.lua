package.path = "packages/gameplay/?.lua;packages/gameplay/?/init.lua"
local vfs = require "vfs"
function vfs.realpath(path)
    local f <close> = io.open(path)
    if f == nil then
        return
    end
    return path
end

local game = require "base.game"
require "type"
require "prototype"

local csystem = require "base.register.csystem"
csystem "vaststars.powergrid.system"
csystem "vaststars.burner.system"
csystem "vaststars.assembling.system"
csystem "vaststars.inserter.system"

local system = require "base.register.system"
local test = system "test"
function test:update(world)
    for v in world:select "generator capacitance:update entity:in" do
        v.capacitance = 0
    end
end

game.init()
require "test_map"
game.rebuild()

local function dump()
    local w = game.w
    local container = require "base.container"
    for v in w:select "chest:in debug:in" do
        local c, n = container.at(v.chest, 1)
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
