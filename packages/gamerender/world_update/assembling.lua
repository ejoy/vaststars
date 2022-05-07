local ecs = ...
local world = ecs.world
local w = world.w

local icontainer = require "gameplay.container"
local iprototype = require "gameplay.prototype"
local ltask = require "ltask"
local ltask_now = ltask.now
local iui = ecs.import.interface "vaststars.gamerender|iui"

local function gettime()
    local _, t = ltask_now() --10ms
    return t * 10
end

local function get_percent(process, total)
    assert(process <= total)
    if process < 0 then
        process = 0
    end
    return (total - process) / total
end

local last_time = 0
local function update_world(world, get_object_func)
    local current = gettime()
    if current - last_time < 500 then
        return
    end
    last_time = current

    local t = {}
    for e in world.ecs:select "assembling:in entity:in" do
        local vsobject = get_object_func(e.entity.x, e.entity.y)
        local assembling = e.assembling
        local speed = 0
        if assembling.recipe ~= 0 then
            local recipe_typeobject = assert(iprototype:query(assembling.recipe))
            speed = recipe_typeobject.time * assembling.speed
        end

        iui.on_data_changed("assembling_changed", vsobject.id, icontainer:get(assembling.container), get_percent(assembling.process, speed))
    end
    return t
end
return update_world
