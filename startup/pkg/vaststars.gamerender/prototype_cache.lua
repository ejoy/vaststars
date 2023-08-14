local ecs = ...
local world = ecs.world
local w = world.w

local prototype_cache_sys = ecs.system "prototype_cache_system"
local iprototype_cache = {}
local fs = require "filesystem"

local cache = {}

function prototype_cache_sys:prototype_restore()
    cache = {}

    for file in fs.pairs(fs.path "/pkg/vaststars.gamerender/prototype_cache") do
        local s = file:stem():string()
        cache[s] = assert(require("prototype_cache." .. s))()
    end
end

function iprototype_cache.get(key)
    return cache[key]
end

return iprototype_cache
