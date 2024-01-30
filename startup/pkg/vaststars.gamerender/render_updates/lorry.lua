local ecs = ...
local world = ecs.world
local w = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local CONFIG <const> = ecs.require "vaststars.prototype|road_track"
local ROAD_TRACKS <const> = CONFIG.TRACKS
local ROAD_TRACKS_MODEL <const> = CONFIG.ROAD_MODEL
local SPEC_TRACKS <const> = CONFIG.SPEC

local START_SLOTS <const> = CONFIG.START
local ALL_DIR = CONSTANT.ALL_DIR

local ROAD_WIDTH_COUNT <const> = CONSTANT.ROAD_WIDTH_COUNT
local ROAD_HEIGHT_COUNT <const> = CONSTANT.ROAD_HEIGHT_COUNT
local ROAD_DIRECTION = {
    [0] = "left",
    [1] = "top",
    [2] = "right",
    [3] = "bottom",
    [4] = "none",
}

local lorry_sys = ecs.system "lorry_system"
local ilorry = {}
local math3d = require "math3d"
local iprototype = require "gameplay.interface.prototype"
local icoord = require "coord"
local create_lorry = ecs.require "lorry"
local mc = import_package "ant.math".constant
local ims = ecs.require "ant.motion_sampler|motion_sampler"
local gameplay_core = require "gameplay.core"
local prefab_slots = require("engine.prefab_parser").slots
local prefab_root = require("engine.prefab_parser").root
local objects = require "objects"
local srt = require "utility.srt"

local start_srts = {}
local cache = {}
local spec_cache = {}
local lorries = {}

local function genKeyFrames(last_srt, x, y, toward, offset)
    local srts, building_srt, c
    local o = objects:coord(x, y)
    if o then
        local typeobject = iprototype.queryByName(o.prototype_name)
        if typeobject.lorry_track and typeobject.lorry_track[x - o.x] and typeobject.lorry_track[x - o.x][y - o.y] then
            local name = typeobject.lorry_track[x - o.x][y - o.y]
            building_srt = o.srt
            c = spec_cache[name][o.dir]
        end
    end

    if not c then
        building_srt = {s = mc.ONE, t = math3d.vector(icoord.position(x, y, ROAD_WIDTH_COUNT, ROAD_HEIGHT_COUNT))}
        c = cache
    end

    if not rawget(c[toward], offset) then
        error(("can not found track keyframes w(%s) from(%s) -> to(%s) offset(%s)"):format(
            toward, ROAD_DIRECTION[toward >> 0x2], ROAD_DIRECTION[toward & 0x3], offset))
    end
    srts = assert(rawget(c[toward], offset))

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
                math3d.matrix {s = building_srt.s, r = building_srt.r, t = building_srt.t},
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

-- key_frames = {s = xx, r = xx, t = xx, step = xx}, ...
local function update(obj, x, y, toward, offset, last_srt, maxprogress, progress)
    if not (obj.x == x and obj.y == y and obj.toward == toward and obj.offset == offset) then
        obj.x, obj.y, obj.toward, obj.offset = x, y, toward, offset
        obj.last_srt = obj.last_srt or last_srt

        local kfs = genKeyFrames(obj.last_srt, x, y, toward, offset)
        local e <close> = world:entity(obj.motion)
        ims.set_keyframes(e, table.unpack(kfs))

        local last = kfs[#kfs]
        obj.last_srt.s = last.s
        obj.last_srt.r = last.r
        obj.last_srt.t = last.t

        ims.set_duration(e, maxprogress, progress, true)
    end
end

local function createLorry(classid, x, y, toward, offset)
    local road_srt = {s = mc.ONE, t = math3d.vector(icoord.position(x, y, ROAD_WIDTH_COUNT, ROAD_HEIGHT_COUNT))}
    local start_srt = start_srts[toward]

    local s, r, t = math3d.srt(
        math3d.mul(
            math3d.matrix {s = road_srt.s, r = road_srt.r, t = road_srt.t},
            math3d.matrix {s = start_srt.s, r = start_srt.r, t = start_srt.t}
        )
    )

    local last_srt = srt.new {
        s = s,
        r = r,
        t = t,
    }
    local typeobject = assert(iprototype.queryById(classid))
    local kfs = genKeyFrames(last_srt, x, y, toward, offset)
    local lorry = create_lorry(typeobject.model, kfs[1].s, kfs[1].r, kfs[1].t)
    lorry.classid = classid
    lorry.last_srt = last_srt

    return lorry
end

local function loadModelTrack(model, tracks)
    local slots = prefab_slots(model)
    assert(slots and next(slots))

    local root_srt = prefab_root(model).data.scene

    local mt = {}
    mt.__index = function (t, k)
        t[k] = setmetatable({}, mt)
        return t[k]
    end

    local cache = setmetatable({}, mt)
    for toward, v in pairs(tracks) do
        assert(rawget(cache, toward) == nil)

        for offset, slot_names in pairs(v) do
            local track_srts = {}
            for _, slot_name in ipairs(slot_names) do
                local slot_srt = slots[slot_name].scene
                local s, r, t = math3d.srt(
                    math3d.mul(
                        math3d.matrix(root_srt),
                        math3d.matrix(slot_srt)
                    )
                )

                track_srts[#track_srts+1] = srt.new {
                    s = s,
                    r = r,
                    t = t,
                }
            end
            cache[toward][offset] = track_srts
        end
    end

    return cache
end

function lorry_sys:prototype_restore()
    cache = loadModelTrack(ROAD_TRACKS_MODEL, ROAD_TRACKS)

    for name, v in pairs(SPEC_TRACKS) do
        spec_cache[name] = {}
        for _, dir in ipairs(ALL_DIR) do
            spec_cache[name][dir] = loadModelTrack(v.model, v.tracks[dir])
        end
    end

    local root_srt = prefab_root(ROAD_TRACKS_MODEL).data.scene
    local slots = prefab_slots(ROAD_TRACKS_MODEL)
    assert(slots and next(slots))

    for toward, slot_name in pairs(START_SLOTS) do
        local s = assert(slots[slot_name])
        local slot_srt = s.scene

        local s, r, t = math3d.srt(
            math3d.mul(
                math3d.matrix(root_srt),
                math3d.matrix(slot_srt)
            )
        )
        start_srts[toward] = srt.new {
            s = s,
            r = r,
            t = t,
        }
    end
end

function lorry_sys:gameworld_update()
    local gameplay_world = gameplay_core.get_world()
    local gameplay_ecs = gameplay_world.ecs

    local l, classid, x, y, offset, toward, item_classid, item_amount, progress, maxprogress, lorry
    for e in gameplay_ecs:select "lorry_changed lorry:in eid:in" do
        l = e.lorry
        classid = l.prototype
        lorry = lorries[e.eid]

        if classid == 0 then
            if lorry then
                lorry:remove()
                lorries[e.eid] = nil
            end
            goto continue
        end

        x, y = l.x, l.y
        offset, toward = (l.z >> 0) & 0xF, (l.z >> 4) & 0xF
        item_classid, item_amount = l.item_prototype, l.item_amount
        progress, maxprogress = l.progress, l.maxprogress

        assert(toward >= 0 and toward <= 0xf)
        assert(progress <= maxprogress)
        assert(offset == 0 or offset == 1)

        if not lorry then
            lorry = createLorry(classid, x, y, toward, offset)
            lorries[e.eid] = lorry
        else
            update(lorry, x, y, toward, offset, lorry.last_srt, maxprogress, maxprogress - progress)
        end

        if l.status == 0 then
            lorry:work()
        else
            lorry:idle()
        end
        lorry:set_item(item_classid, item_amount)
        ::continue::
    end
    gameplay_ecs:clear("lorry_changed")
end

function lorry_sys:gameworld_clean()
    for _, lorry in pairs(lorries) do
        lorry:remove()
    end
    lorries = {}
end

function ilorry.get(lorry_id)
    return lorries[lorry_id]
end

return ilorry
