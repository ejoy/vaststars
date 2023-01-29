local ecs = ...
local world = ecs.world
-- local timer = ecs.import.interface "ant.timer|itimer"
local gameplay_core = require "gameplay.core"
local global = require "global"
local entity_create = world:sub {"gameplay", "create_entity"}
local entity_remove = world:sub {"gameplay", "remove_entity"}

local function create_statistic_node(cfg, consumer)
    return {
        cfg = cfg,
        period = 51,
        tail = 1,
        head = 1,
        frames = {},
        drain = 0,
        power = 0,
        state = 0,
        count = 0,
        consumer = consumer
    }
end
local function update_world(world, get_object_func)
    global.frame_count = global.frame_count + 1
    -- local delta_time = timer.delta()
    local statistic = global.statistic
    for _, _, eid, cfg in entity_create:unpack() do
        statistic.pending_eid[eid] = cfg
    end
    for _, _, eid in entity_remove:unpack() do
        if statistic.power[eid] then
            local key = statistic.power[eid].cfg.name
            statistic.power_group[key].count = statistic.power_group[key].count -1
            statistic.power[eid] = nil
        end
    end
    local finish = {}
    for eid, cfg in pairs(statistic.pending_eid) do
        local e = gameplay_core.get_entity(eid)
        if e then
            if cfg.power then
                if e.consumer or e.generator then
                    statistic.power[eid] = create_statistic_node(cfg, e.consumer)
                    local pg = statistic.power_group[cfg.name]
                    if not pg then
                        pg = create_statistic_node(cfg, e.consumer)
                        statistic.power_group[cfg.name] = pg
                    end
                    pg.count = pg.count + 1
                end
            end
            finish[#finish + 1] = eid
        end
    end

    for _, eid in ipairs(finish) do
        statistic.pending_eid[eid] = nil
    end

    local function upate_power(st, power, total)
        local consume = power < 0
        local frame_power = math.abs(power)
        st.power = st.power + frame_power
        if total then
            if consume then
                total.power_consumed = total.power_consumed + frame_power
            else
                total.power_generated = total.power_generated + frame_power
            end
            
        end
        if not st.frames[st.head] then
            st.frames[st.head] = {power = frame_power}
        else
            st.frames[st.head].power = frame_power
        end
        st.head = (st.head >= st.period) and 1 or st.head + 1
        if st.head == st.tail then
            local fp = st.frames[st.tail]
            st.power = st.power - fp.power
            if total then
                if consume then
                    total.power_consumed = total.power_consumed - fp.power
                else
                    total.power_generated = total.power_generated - fp.power
                end
            end
            st.tail = (st.tail >= st.period) and 1 or st.tail + 1
        end
    end

    for eid, st in pairs(statistic.power) do
        local e = gameplay_core.get_entity(eid)
        if not e or not e.capacitance then
            goto continue
        end
        local power = e.capacitance.delta
        upate_power(st, power, statistic)
        upate_power(statistic.power_group[st.cfg.name], power)
        ::continue::
    end
end
return update_world