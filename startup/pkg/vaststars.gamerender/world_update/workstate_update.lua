local global = require "global"
local update_interval = 25 --update per 25 frame
local counter = 1
local math3d = require "math3d"
local STATE_WORKING  = math3d.constant("v4", {0.0, 1.0, 0.0, 1})
local STATE_NO_POWER = math3d.constant("v4", {1.0, 1.0, 0.0, 1})
local last_frame_count = 0
local function update_world(world, get_object_func)
    counter = counter + 1
    if counter < update_interval then
        return
    end
    counter = 1
    local statistic = global.statistic
    for e in world.ecs:select "entity:in eid:in" do
        local vsobject = get_object_func(e.entity.x, e.entity.y)
        local st = statistic.power[e.eid]
        if st then
            local game_object = vsobject.game_object
            -- is working ?
            if st.power < math.floor((global.frame_count - last_frame_count) * 0.5) * st.cfg.power then
                game_object.on_idle()
                vsobject:emissive_color_update(STATE_NO_POWER)
                vsobject:animation_name_update("idle")
            else
                game_object.on_work()
                vsobject:emissive_color_update(STATE_WORKING)
                vsobject:animation_name_update("work")
            end
        end
    end
    last_frame_count = global.frame_count
end
return update_world