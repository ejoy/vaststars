local ecs = ...
local world = ecs.world
local w = world.w

local icontainer = require "gameplay.container"
local ltask = require "ltask"
local ltask_now = ltask.now
local iui = ecs.import.interface "vaststars.gamerender|iui"

local function gettime()
    local _, t = ltask_now() --10ms
    return t * 10
end

local last_time = 0
local function update_world(world, get_object_func)
    local current = gettime()
    if current - last_time < 1000 then
        return
    end
    last_time = current

    local t = {}
    for e in world.ecs:select "chest:in entity:in" do
        local vsobject = get_object_func(e.entity.x, e.entity.y)
        local chest = e.chest
        iui.on_data_changed("chest_container_changed", vsobject.id, icontainer:get(chest.container))
    end
    return t
end
return update_world