local ecs = ...
local world = ecs.world
local w = world.w

local global = require "global"
local tracedoc = require "utility.tracedoc"
local ichest = require "gameplay.interface.chest"

local ltask = require "ltask"
local ltask_now = ltask.now
local last_update_time

local function _gettime()
    local _, t = ltask_now() --10ms
    return t * 10
end

local function update_world(world)
    local current = _gettime()
    last_update_time = last_update_time or current
    if current - last_update_time > 1000 then
        last_update_time = current
        global.base_chest_cache = tracedoc.new(ichest.base_collect_item(world))
    end
end
return update_world