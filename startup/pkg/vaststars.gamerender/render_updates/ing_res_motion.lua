local ecs = ...
local world = ecs.world
local w = world.w

local ims = ecs.import.interface "ant.motion_sampler|imotion_sampler"
local ivs = ecs.import.interface "ant.scene|ivisible_state"
local imotion = ecs.require "imotion"

local ing_res_motion_sys = ecs.system "ing_res_motion_system"

local motions = {}
local motion_caches = {}

function ing_res_motion_sys:gameworld_update()
    local time_step = 1.0 / 30
    local remove_idx = {}
    for index, mobj in ipairs(motions) do
        if not mobj.inited then
            mobj.inited = true
            local e <close> = w:entity(mobj.motion)
            -- ims.set_keyframes(e, {t = mobj.from, step = 0.0}, {t = mobj.to,  step = 1.0})
            -- ivs.set_state(e, "main_view", true) -- TODO
        end
        local e <close> = w:entity(mobj.motion)
        mobj.elapsed_time = mobj.elapsed_time + time_step
        local ratio = mobj.elapsed_time / mobj.duration
        if ratio > 1.0 then
            if mobj.repeat_count > 1 then
                mobj.repeat_count = mobj.repeat_count - 1
                mobj.elapsed_time = 0
                ims.set_ratio(e, 0)
            else
                -- ivs.set_state(e, "main_view", false)
                local cache = motion_caches[mobj.prefab]
                if not cache then
                    motion_caches[mobj.prefab] = {mobj}
                else
                    table.insert(cache, mobj)
                end
                remove_idx[#remove_idx + 1] = index
            end
        else
            -- ims.set_ratio(e, ratio)
        end
    end

    for _, value in ipairs(remove_idx) do
        -- table.remove(motions, value) -- TODO
    end
end

function ing_res_motion_sys:gameworld_clean()
    motions = {}
    motion_caches = {}
end

local iing_res_motion = ecs.interface "iing_res_motion"

function iing_res_motion.create(prefab, from, to, duration, repeat_count)
    local cache = motion_caches[prefab]
    if not cache or #cache < 1 then
        local motion = imotion.create_motion_object(nil, nil, from)
        imotion.sampler_group:create_instance(prefab, motion)
        motions[#motions + 1] = {inited = false, prefab = prefab, from = from, to = to, duration = duration, repeat_count = repeat_count or 1, elapsed_time = 0, motion = motion }
    else
        local m = table.remove(cache, #cache)
        m.from = from
        m.to = to
        m.duration = duration
        m.repeat_count = 1
        m.elapsed_time = 0
        m.inited = false
        motions[#motions + 1] = m
    end
end