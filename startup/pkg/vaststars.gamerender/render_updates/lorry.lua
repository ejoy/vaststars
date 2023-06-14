local ecs = ...
local world = ecs.world
local w = world.w

local lorry_sys = ecs.system "lorry_system"
local ilorry = ecs.interface "ilorry"
local math3d = require "math3d"
local iprototype = require "gameplay.interface.prototype"
local iterrain = ecs.require "terrain"
local create_lorry = ecs.require "lorry"
local iroadnet_converter = require "roadnet_converter"
local iprototype_cache = require "gameplay.prototype_cache.init"
local mask_to_prototype_name_dir = iroadnet_converter.mask_to_prototype_name_dir
local mc = import_package "ant.math".constant
local ims = ecs.import.interface "ant.motion_sampler|imotion_sampler"
local gameplay_core = require "gameplay.core"
local gameplay = import_package "vaststars.gameplay"
local iroad = gameplay.interface "road"

local ROAD_TILE_WIDTH_SCALE <const> = 2
local ROAD_TILE_HEIGHT_SCALE <const> = 2
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local ROAD_DIRECTION = {
    [0] = "left",
    [1] = "top",
    [2] = "right",
    [3] = "bottom",
    [4] = "none",
}

local lorries = {}

local function __rotate_dir(dir, entity_dir)
    local t = iprototype.dir_tonumber(entity_dir) - iprototype.dir_tonumber('N')
    return (dir - t) % 4
end

local function __rotate_toward(toward, entity_dir)
    local s = __rotate_dir(toward >> 0x2, entity_dir) -- high 2 bits is indir
    local e = __rotate_dir(toward &  0x3, entity_dir) -- low  2 bits is outdir
    return s << 2 | e
end

local function __gen_keyframes(last_srt, mask, x, y, toward, offset)
    local prototype_name, dir = mask_to_prototype_name_dir(mask)
    local road_srt = {s = mc.ONE, r = ROTATORS[dir], t = math3d.vector(iterrain:get_position_by_coord(x, y, ROAD_TILE_WIDTH_SCALE, ROAD_TILE_HEIGHT_SCALE))}
    local cache = iprototype_cache.get("lorry_manager").cache
    if not rawget(cache[prototype_name][dir][toward], offset) then
        log.error(("can not found track keyframes(%s, %s), w(%s) -> (%s) from(%s) -> to(%s) offset(%s)"):format(
            prototype_name, dir,
            toward, __rotate_toward(toward, dir),
            ROAD_DIRECTION[toward >> 0x2], ROAD_DIRECTION[toward & 0x3],
            offset))
        return {}
    end
    local srts = assert(rawget(cache[prototype_name][dir][toward], offset))
    local step = 1 / #srts
    local value = 0
    local key_frames = {}

    key_frames[#key_frames+1] = {
        s = last_srt.s,
        r = last_srt.r,
        t = last_srt.t,
        step = value,
    }
    value = value + step

    for idx, srt in ipairs(srts) do
        if idx == #srt then
            value = 1
        end

        local road_mat = math3d.matrix {s = road_srt.s, r = road_srt.r, t = road_srt.t}
        local mat = math3d.matrix {s = srt.s, r = srt.r, t = srt.t}
        mat = math3d.mul(road_mat, mat)
        local s, r, t = math3d.srt(mat)
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
motion_events["update_keyframes_on_change"] = function(obj, e, mask, x, y, toward, offset, last_srt)
    if obj.mask == mask and obj.x == x and obj.y == y and obj.toward == toward and obj.offset == offset then
        return
    end
    obj.mask, obj.x, obj.y, obj.toward, obj.offset = mask, x, y, toward, offset
    obj.last_srt = obj.last_srt or last_srt

    local keyframes = __gen_keyframes(obj.last_srt, mask, x, y, toward, offset)
    assert(#keyframes > 0)
    local last = keyframes[#keyframes]
    obj.last_srt = {s = math3d.ref(last.s), r = math3d.ref(last.r), t = math3d.ref(last.t)}

    ims.set_keyframes(e, table.unpack(keyframes))
end
motion_events["set_ratio"] = function (_, e, progress, maxprogress)
    assert(progress <= maxprogress)
    ims.set_ratio(e, progress/maxprogress)
end

local function __create_lorry(classid, mask, x, y, toward, offset)
    if classid == 0 then
        log.error("lorry classid is 0")
        return
    end

    local start = iprototype_cache.get("lorry_manager").start
    local prototype_name, dir = mask_to_prototype_name_dir(mask)
    local road_srt = {s = mc.ONE, r = ROTATORS[dir], t = math3d.vector(iterrain:get_position_by_coord(x, y, ROAD_TILE_WIDTH_SCALE, ROAD_TILE_HEIGHT_SCALE))}
    if not rawget(start, prototype_name) then
        log.error(("can not found start keyframes(%s, %s)"):format(prototype_name, dir))
        return
    end
    local srt = start[prototype_name]
    local road_mat = math3d.matrix {s = road_srt.s, r = road_srt.r, t = road_srt.t}
    local mat = math3d.matrix {s = srt.s, r = srt.r, t = srt.t}
    mat = math3d.mul(road_mat, mat)
    local s, r, t = math3d.srt(mat)
    local last_srt = {s = math3d.ref(s), r = math3d.ref(r), t = math3d.ref(t)}

    local typeobject = assert(iprototype.queryById(classid))
    local kfs = __gen_keyframes(last_srt, mask, x, y, toward, offset)
    assert(kfs[1])

    local lorry = create_lorry(typeobject.model, kfs[1].s, kfs[1].r, kfs[1].t, motion_events)
    lorry.classid = classid
    lorry.last_srt = last_srt

    return lorry
end

function lorry_sys:gameworld_update()
    local gameplay_world = gameplay_core.get_world()

    local new_lorries = {}
    local x, y, offset, toward, mask
    for lorry_id, classid, item_classid, item_amount, mc, progress, maxprogress in gameplay_world:roadnet_each_lorry() do
        x = mc & 0xFF
        y = (mc >> 8) & 0xFF
        x, y = x * ROAD_TILE_WIDTH_SCALE, y * ROAD_TILE_HEIGHT_SCALE
        offset = (mc >> 16) & 0xF
        toward = (mc >> 20) & 0xF
        mask = assert(iroad.get(gameplay_core.get_world(), x, y))

        local lorry = lorries[lorry_id]
        if not lorry then
            lorry = __create_lorry(classid, mask, x, y, toward, offset)
            if not lorry then
                goto continue
            end
        end

        assert(toward >= 0 and toward <= 0xf)
        assert(progress <= maxprogress)
        assert(offset == 0 or offset == 1)

        lorry:motion_opt("update_keyframes_on_change", mask, x, y, toward, offset, lorry.last_srt)
        lorry:motion_opt("set_ratio", maxprogress - progress, maxprogress)
        lorry:set_item(item_classid, item_amount)

        new_lorries[lorry_id] = lorry
        lorries[lorry_id] = nil
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

function ilorry.remove(lorry_id)
    local lorry = lorries[lorry_id]
    if lorry then
        lorry:remove()
        lorries[lorry_id] = nil
    end
end