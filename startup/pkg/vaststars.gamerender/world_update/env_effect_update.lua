local ecs = ...
local world = ecs.world
local w = world.w

local iefk = ecs.import.interface "ant.efk|iefk"

local timer = ecs.import.interface "ant.timer|itimer"
local storm_effect
local storm_current_time = 0
local storm_rest_time = 0
local storm_life = 20
local storm_interval = 40
local show_shorm = true

return function (world)
    -- if not storm_effect then
    --     local mq = w:first("main_queue camera_ref:in")
    --     storm_effect = iefk.create("/pkg/vaststars.resources/effect/efk/sandstorm.efk", {
    --         auto_play = true,
    --         loop = false,
    --         speed = 1.0,
    --         scene = {t={0, 0, 0}, s = 30, parent = mq.camera_ref}
    --     })
    -- end
    -- if show_shorm then
    --     storm_current_time = storm_current_time + timer.delta() * 0.001
    --     if storm_current_time >= storm_life then
    --         show_shorm = false
    --         storm_current_time = 0
    --         local e <close> = w:entity(storm_effect)
    --         iefk.stop(e, true)
    --     end
    -- else
    --     storm_rest_time = storm_rest_time + timer.delta() * 0.001
    --     if storm_rest_time >= storm_interval then
    --         show_shorm = true
    --         storm_rest_time = 0
    --         local e <close> = w:entity(storm_effect)
    --         iefk.play(e)
    --     end
    -- end
end