local ecs = ...
local world = ecs.world
local w = world.w

local timer = ecs.import.interface "ant.timer|itimer"
local gameplay_core = require "gameplay.core"
local global = require "global"
local entity_create = world:sub {"gameplay", "create_entity"}
local entity_remove = world:sub {"gameplay", "remove_entity"}

local function create_statistic_node(cfg, consumer)
    return {
        cfg = cfg,
        tail = 1,
        head = 1,
        frames = {},
        drain = 0,
        power = 0,
        state = 0,
        consumer = consumer,
        time = 0
    }
end
local frame_period = 51
local filter_statistic = {
    ["5s"] = {interval = 0.1, elapsed = 0.0, maxsec = 5},
    ["1m"] = {interval = 1.2, elapsed = 0.0, maxsec = 60},
    ["10m"] = {interval = 12.0, elapsed = 0.0, maxsec = 600},
    ["1h"] = {interval = 72.0, elapsed = 0.0, maxsec = 3600},
}
local init_group_statistic = false
local function update_world(world)
    local statistic = global.statistic
    if not init_group_statistic then
        init_group_statistic = true
        statistic.power_consumed = {}
        statistic.power_generated = {}
        for key, _ in pairs(filter_statistic) do
            statistic.power_consumed[key] = create_statistic_node(true)
            statistic.power_generated[key] = create_statistic_node()
        end
    end
    global.frame_count = global.frame_count + 1
    local delta_s = timer.delta() * 0.001
    for key, fs in pairs(filter_statistic) do
        fs.elapsed = fs.elapsed + delta_s
        local consumed = statistic.power_consumed[key]
        if consumed.time < fs.maxsec then
            consumed.time = consumed.time + delta_s
        end
        local generated = statistic.power_generated[key]
        if generated.time < fs.maxsec then
            generated.time = generated.time + delta_s
        end
    end

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
                        pg = {}
                        for filter, _ in pairs(filter_statistic) do
                            pg[filter] = create_statistic_node(cfg, e.consumer)
                        end
                        pg.count = 0
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

    local function step_frame_head(st)
        st.head = (st.head >= frame_period) and 1 or st.head + 1
        if st.head == st.tail then
            local fp = st.frames[st.tail]
            if fp then
                st.power = st.power - fp.power
                fp.power = 0
                st.tail = (st.tail >= frame_period) and 1 or st.tail + 1
            end
        end
    end
    local function do_update_power(st, power, step)
        local frame_power = math.abs(power)
        st.power = st.power + frame_power
        if not st.frames[st.head] then
            st.frames[st.head] = {power = frame_power}
        else
            st.frames[st.head].power = st.frames[st.head].power + frame_power
        end
        if step then
            step_frame_head(st)
        end
    end

    local function upate_power(st, power)
        do_update_power(st, power, true)
        local group = statistic.power_group[st.cfg.name]
        for filter, value in pairs(filter_statistic) do
            do_update_power(group[filter], power)
            if power < 0 then
                do_update_power(statistic.power_consumed[filter], power)
            else
                do_update_power(statistic.power_generated[filter], power)
            end
        end
    end

    for eid, st in pairs(statistic.power) do
        local e = gameplay_core.get_entity(eid)
        if not e or not e.capacitance then
            goto continue
        end
        upate_power(st, e.capacitance.delta)
        ::continue::
    end
    --
    local power_group = statistic.power_group
    for filter, value in pairs(filter_statistic) do
        local step = false
        if value.elapsed > value.interval then
            value.elapsed = value.elapsed - value.interval
            step = true
        end
        for _, group in pairs(power_group) do
            if step and group.count > 0 then
                step_frame_head(group[filter])
            end
        end
        if step then
            step_frame_head(statistic.power_consumed[filter])
            step_frame_head(statistic.power_generated[filter])
        end
    end
end
return update_world