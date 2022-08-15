local iprototype = require "gameplay.interface.prototype"
local itypes = require "gameplay.interface.types"
local global = require "global"
local update_interval = 25 --update per 25 frame
local counter = 1
local function update_world(world, get_object_func)
    counter = counter + 1
    if counter < update_interval then
        return
    end
    counter = 1
    local statistic = global.statistic
    for e in world.ecs:select "mining:in entity:in eid:in" do
        local vsobject = get_object_func(e.entity.x, e.entity.y)
        local st = statistic.power[e.eid]
        if st then
            local game_object = vsobject.game_object
            -- is working ?
            if st.power < 25 * st.cfg.power then
                if game_object.stop_effect then
                    game_object.stop_effect()
                end
            else
                if game_object.play_effect and not game_object.is_effect_playing() then
                    game_object.play_effect()
                end
            end
        end
    end
end
return update_world