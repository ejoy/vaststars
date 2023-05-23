local ecs = ...
local world = ecs.world
local w = world.w

-- local ims = ecs.import.interface "ant.motion_sampler|imotion_sampler"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ivs = ecs.import.interface "ant.scene|ivisible_state"
local imotion = ecs.require "imotion"
local ltween = require "motion.tween"
local ing_res_motion_sys = ecs.system "ing_res_motion_system"

local motions = {}
local motion_caches = {}
local function set_visible(inst, visible)
    local alleid = inst.tag["*"]
    for _, eid in ipairs(alleid) do
        local e <close> = w:entity(eid, "visible_state?in")
        if e.visible_state then
            ivs.set_state(e, "main_view", visible)
        end
    end
end
function ing_res_motion_sys:gameworld_update()
    local time_step = 1.0 / 30
    local valid_motions = {}
    for index, mobj in ipairs(motions) do
        mobj.elapsed_time = mobj.elapsed_time + time_step
        local ratio = mobj.elapsed_time / mobj.duration
        if ratio > 1.0 then
            if mobj.repeat_count > 1 then
                mobj.repeat_count = mobj.repeat_count - 1
                mobj.elapsed_time = 0
            else
                set_visible(mobj.inst, false)
                local cache = motion_caches[mobj.prefab]
                if not cache then
                    motion_caches[mobj.prefab] = {mobj}
                else
                    table.insert(cache, mobj)
                end
            end
        else
            valid_motions[#valid_motions + 1] = mobj
        end
    end
    motions = valid_motions
    -- for _, value in ipairs(remove_idx) do
    --     table.remove(motions, value)
    -- end
end

function ing_res_motion_sys:gameworld_clean()
    motions = {}
    motion_caches = {}
end

local iing_res_motion = ecs.interface "iing_res_motion"

function iing_res_motion.create(prefab, from, to, duration, repeat_count)
    local cache = motion_caches[prefab]
    if not cache or #cache < 1 then
        local motion = imotion.create_motion_object(nil, nil, from, nil, true)
        local inst = imotion.sampler_group:create_instance(prefab, motion.id)
        motions[#motions + 1] = {prefab = prefab, inst = inst, duration = duration, repeat_count = repeat_count or 1, elapsed_time = 0, motion = motion }
    else
        local m = table.remove(cache, #cache)
        m.duration = duration
        m.repeat_count = 1
        m.elapsed_time = 0
        local e <close> = w:entity(m.motion.id)
        iom.set_position(e, from)
        set_visible(m.inst, true)
        motions[#motions + 1] = m
    end
    local mobj = motions[#motions]
    mobj.motion:send("motion", "set_duration", 1000)
    mobj.motion:send("motion", "set_tween", ltween.type("Linear"), ltween.type("Linear"))
    mobj.motion:send("motion", "set_keyframes", {t = from, step = 0.0}, {t = to,  step = 1.0})
end