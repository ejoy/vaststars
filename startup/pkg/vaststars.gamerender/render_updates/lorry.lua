local ecs = ...
local world = ecs.world
local w = world.w

local lorry_sys = ecs.system "lorry_system"
local ilorry = ecs.interface "ilorry"
local math3d = require "math3d"
local iprototype = require "gameplay.interface.prototype"
local iterrain = ecs.require "terrain"
local create_lorry = ecs.require "lorry"
local mc = import_package "ant.math".constant
local ims = ecs.import.interface "ant.motion_sampler|imotion_sampler"
local gameplay_core = require "gameplay.core"
local prefab_slots = require("engine.prefab_parser").slots
local prefab_root = require("engine.prefab_parser").root
local CONFIG <const> = import_package "vaststars.prototype".load("road_track")
local ROAD_TRACKS <const> = CONFIG.TRACKS
local START_SLOTS <const> = CONFIG.START
local ROAD_TRACK_MODEL <const> = CONFIG.MODEL

local ROAD_TILE_WIDTH_SCALE <const> = 2
local ROAD_TILE_HEIGHT_SCALE <const> = 2
local ROAD_DIRECTION = {
    [0] = "left",
    [1] = "top",
    [2] = "right",
    [3] = "bottom",
    [4] = "none",
}

local start_srts = {}
local cache = {}
local lorries = {}

local function __gen_keyframes(last_srt, x, y, toward, offset)
    local road_srt = {s = mc.ONE, t = math3d.vector(iterrain:get_position_by_coord(x, y, ROAD_TILE_WIDTH_SCALE, ROAD_TILE_HEIGHT_SCALE))}
    if not rawget(cache[toward], offset) then
        assert(false, ("can not found track keyframes w(%s) from(%s) -> to(%s) offset(%s)"):format(
            toward, ROAD_DIRECTION[toward >> 0x2], ROAD_DIRECTION[toward & 0x3], offset))
    end
    local srts = assert(rawget(cache[toward], offset))
    local step = 1 / #srts
    local key_frames = {}

    key_frames[#key_frames+1] = {
        s = last_srt.s,
        r = last_srt.r,
        t = last_srt.t,
        step = 0,
    }

    local value = step
    for idx, srt in ipairs(srts) do
        if idx == #srt then
            value = 1
        end

        local s, r, t = math3d.srt(
            math3d.mul(
                math3d.matrix {s = road_srt.s, r = road_srt.r, t = road_srt.t},
                math3d.matrix {s = srt.s, r = srt.r, t = srt.t}
            )
        )
        key_frames[#key_frames+1] = {
            s = s,
            r = r,
            t = t,
            step = value,
        }

        value = value + step
    end
    return key_frames
end

local motion_events = {}
-- key_frames = {s = xx, r = xx, t = xx, step = xx}, ...
motion_events["update_keyframes_on_change"] = function(obj, e, x, y, toward, offset, last_srt)
    if obj.x == x and obj.y == y and obj.toward == toward and obj.offset == offset then
        return
    end
    obj.x, obj.y, obj.toward, obj.offset = x, y, toward, offset
    obj.last_srt = obj.last_srt or last_srt

    local kfs = __gen_keyframes(obj.last_srt, x, y, toward, offset)
    local last = kfs[#kfs]
    obj.last_srt = {s = math3d.ref(last.s), r = math3d.ref(last.r), t = math3d.ref(last.t)}

    ims.set_keyframes(e, table.unpack(kfs))
end
motion_events["set_ratio"] = function (_, e, progress, maxprogress)
    assert(progress <= maxprogress)
    ims.set_ratio(e, progress/maxprogress)
end

local function __create_lorry(classid, x, y, toward, offset)
    local road_srt = {s = mc.ONE, t = math3d.vector(iterrain:get_position_by_coord(x, y, ROAD_TILE_WIDTH_SCALE, ROAD_TILE_HEIGHT_SCALE))}
    local start_srt = start_srts[toward]

    local s, r, t = math3d.srt(
        math3d.mul(
            math3d.matrix {s = road_srt.s, r = road_srt.r, t = road_srt.t},
            math3d.matrix {s = start_srt.s, r = start_srt.r, t = start_srt.t}
        )
    )

    local last_srt = {s = math3d.ref(s), r = math3d.ref(r), t = math3d.ref(t)}
    local typeobject = assert(iprototype.queryById(classid))
    local kfs = __gen_keyframes(last_srt, x, y, toward, offset)
    local lorry = create_lorry(typeobject.model, kfs[1].s, kfs[1].r, kfs[1].t, motion_events)
    lorry.classid = classid
    lorry.last_srt = last_srt

    return lorry
end

function lorry_sys:prototype_restore()
    local mt = {}
    mt.__index = function (t, k)
        t[k] = setmetatable({}, mt)
        return t[k]
    end

    cache = setmetatable({}, mt)

    local slots = prefab_slots(ROAD_TRACK_MODEL)
    assert(slots and next(slots))

    local root_srt = prefab_root(ROAD_TRACK_MODEL).data.scene

    for toward, v in pairs(ROAD_TRACKS) do
        assert(rawget(cache, toward) == nil)

        for offset, slot_names in pairs(v) do
            local track_srts = {}
            for _, slot_name in ipairs(slot_names) do
                local slot_srt = {
                    s = math3d.vector(slots[slot_name].scene.s),
                    r = math3d.quaternion(slots[slot_name].scene.r),
                    t = math3d.vector(slots[slot_name].scene.t),
                }
                local s, r, t = math3d.srt(
                    math3d.mul(
                        math3d.matrix(root_srt),
                        math3d.matrix(slot_srt)
                    )
                )

                track_srts[#track_srts+1] = {
                    s = math3d.ref(s),
                    r = math3d.ref(r),
                    t = math3d.ref(t),
                }
            end
            cache[toward][offset] = track_srts
        end
    end

    for toward, slot_name in pairs(START_SLOTS) do
        local s = assert(slots[slot_name])
        local slot_srt = {
            s = math3d.vector(s.scene.s),
            r = math3d.quaternion(s.scene.r),
            t = math3d.vector(s.scene.t),
        }

        local s, r, t = math3d.srt(
            math3d.mul(
                math3d.matrix(root_srt),
                math3d.matrix(slot_srt)
            )
        )
        start_srts[toward] = {
            s = math3d.ref(s),
            r = math3d.ref(r),
            t = math3d.ref(t),
        }
    end
end

function lorry_sys:gameworld_update()
    local gameplay_world = gameplay_core.get_world()

    local new_lorries = {}
    local x, y, offset, toward, item_classid, item_amount, progress, maxprogress, lorry
    for e in gameplay_world.ecs:select "lorry:in eid:in" do
        local l = e.lorry
        local classid = l.classid
        if classid == 0 then
            goto continue
        end

        x, y = l.x, l.y
        offset, toward = (l.z >> 0) & 0xF, (l.z >> 4) & 0xF
        item_classid, item_amount = l.item_classid, l.item_amount
        progress, maxprogress = l.progress, l.maxprogress

        assert(toward >= 0 and toward <= 0xf)
        assert(progress <= maxprogress)
        assert(offset == 0 or offset == 1)

        lorry = lorries[e.eid]
        if not lorry then
            lorry = __create_lorry(classid, x, y, toward, offset)
        end
        lorry:motion_opt("update_keyframes_on_change", x, y, toward, offset, lorry.last_srt)
        lorry:motion_opt("set_ratio", maxprogress - progress, maxprogress)
        lorry:set_item(item_classid, item_amount)

        new_lorries[e.eid] = lorry
        lorries[e.eid] = nil
        ::continue::
    end

    for _, lorry in pairs(lorries) do
        lorry:remove()
    end

    lorries = new_lorries
end

function lorry_sys:gameworld_clean()
    for _, obj in pairs(lorries) do
        obj:remove()
    end
    lorries = {}
end

function ilorry.get(lorry_id)
    return lorries[lorry_id]
end
