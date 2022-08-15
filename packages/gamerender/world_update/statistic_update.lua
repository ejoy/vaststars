local ecs = ...
local world = ecs.world
-- local timer = ecs.import.interface "ant.timer|itimer"
local gameplay_core = require "gameplay.core"
local global = require "global"
local entity_create = world:sub {"gameplay", "create_entity"}
local entity_remove = world:sub {"gameplay", "remove_entity"}

local function create_statistic_node(cfg)
    return {
        cfg = cfg,
        period = 50,
        tail = 1,
        head = 1,
        frames = {},
        drain = 0,
        power = 0,
    }
    
end
local function update_world(world, get_object_func)
    -- local delta_time = timer.delta()
    local statistic = global.statistic
    for _, _, eid, cfg in entity_create:unpack() do
        statistic.pending_eid[eid] = cfg
    end
    for _, _, eid in entity_remove:unpack() do
        if statistic.power[eid] then
            statistic.power[eid] = nil
        end
    end
    local finish = {}
    for eid, cfg in pairs(statistic.pending_eid) do
        local e = gameplay_core.get_entity(eid)
        if e then
            if cfg.power then
                if e.consumer then
                    statistic.power[eid] = create_statistic_node(cfg)
                end
            end
            finish[#finish + 1] = eid
        end
    end

    for _, eid in ipairs(finish) do
        statistic.pending_eid[eid] = nil
    end

    for eid, st in pairs(statistic.power) do
        local drain = st.cfg.drain and st.cfg.drain or st.cfg.power/30
        local frame_power = 0
        local frame_drain = 0
        local e = gameplay_core.get_entity(eid)
        if not e or not e.consumer then
            goto continue
        end
        --TODO: remove consumer.working
--[[
        local working = e.consumer.working
        if working > 0 then
            frame_drain = drain
            st.drain = st.drain + frame_drain
        end
        if working > 1 then
            frame_power = st.cfg.power
            st.power = st.power + frame_power
        end
        if working ~= 0 then
            statistic.power_consumed = statistic.power_consumed + frame_power + frame_drain
        end
        if not st.frames[st.head] then
            st.frames[st.head] = {drain = frame_drain, power = frame_power}
        else
            local frame = st.frames[st.head]
            frame.drain = frame_drain
            frame.power = frame_power
        end
        st.head = (st.head >= st.period) and 1 or st.head + 1
        if st.head == st.tail then
            local fp = st.frames[st.tail]
            st.drain = st.drain - fp.drain
            st.power = st.power - fp.power
            statistic.power_consumed = statistic.power_consumed - fp.drain - fp.power
            st.tail = (st.tail >= st.period) and 1 or st.tail + 1
        end
--]]
        ::continue::
    end
end
return update_world