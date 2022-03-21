local ecs = ...
local world = ecs.world
local w = world.w

local inserter_sys = ecs.system "inserter_system"
local gameplay = ecs.require "gameplay"

local function packCoord(x, y)
    return x | (y<<8)
end

local cache = {}
local function print_e(inserter)
    local entity = inserter.entity
    local inserter = inserter.inserter
    local coord = packCoord(entity.x, entity.y)
    cache[coord] = cache[coord] or {}

    if cache[coord].status ~= inserter.status or cache[coord].process ~= inserter.process then
        print("print inserter", entity.x, entity.y, inserter.status, inserter.process)
        cache[coord].status = inserter.status
        cache[coord].process = inserter.process
    end
end

function inserter_sys.update_world()
    for e in gameplay.select "inserter:in entity:in" do
        print_e(e)
    end
end
