local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local lorries = {}
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
local ROADNET_MASK_ENDPOINT <const> = require("gameplay.interface.constant").ROADNET_MASK_ENDPOINT
local ROAD_DIRECTION = {
    [0] = "left",
    [1] = "top",
    [2] = "right",
    [3] = "bottom",
    [4] = "none",
};

local function rotate_dir(dir, entity_dir)
    local t = iprototype.dir_tonumber(entity_dir) - iprototype.dir_tonumber('N')
    return (dir - t) % 4
end

local function __gen_keyframes(mask, x, y, toward)
    local prototype_name, dir = mask_to_prototype_name_dir(mask)
    local road_srt = {s = mc.ONE, r = ROTATORS[dir], t = math3d.vector(iterrain:get_position_by_coord(x, y, ROAD_TILE_WIDTH_SCALE, ROAD_TILE_HEIGHT_SCALE))}
    local cache = iprototype_cache.get("lorry_manager").cache
    if not rawget(cache[prototype_name][dir], toward) then
        log.error(("can not found track keyframes(%s, %s), w(%s) from(%s) -> to(%s)"):format(prototype_name, dir, toward, ROAD_DIRECTION[toward >> 0x2], ROAD_DIRECTION[toward &  0x3]))
        -- local s = rotate_dir(toward >> 0x2, dir) -- high 2 bits is indir
        -- local e = rotate_dir(toward &  0x3, dir) -- low  2 bits is outdir
        -- log.error(("can not found track keyframes(%s, %s), toward(%s) -> (%s), from(%s) -> to(%s)"):format(prototype_name, dir, toward, s << 2 | e, ROAD_DIRECTION[s], ROAD_DIRECTION[e]))
        return {}
    end
    local srts = assert(rawget(cache[prototype_name][dir], toward))

    local step = 1 / (#srts - 1)
    local value = 0
    local key_frames = {}

    for idx, srt in ipairs(srts) do
        if idx == #srt then
            value = 1
        end

        local road_mat = math3d.matrix {s = road_srt.s, r = road_srt.r, t = road_srt.t}
        local mat = math3d.matrix {s = srt.s, r = srt.r, t = srt.t}
        local mat = math3d.mul(road_mat, mat)
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
motion_events["update_keyframes_on_change"] = function(obj, e, mask, x, y, toward)
    if obj.mask == mask and obj.x == x and obj.y == y and obj.toward == toward then
        return
    end
    obj.mask, obj.x, obj.y, obj.toward = mask, x, y, toward
    ims.set_keyframes(e, table.unpack(__gen_keyframes(mask, x, y, toward)))
end
motion_events["set_ratio"] = function (_, e, progress, maxprogress)
    assert(progress <= maxprogress)
    ims.set_ratio(e, progress/maxprogress)
end

local function __get_or_create_lorry(lorry_id, classid, mask, x, y, toward)
    local lorry = lorries[lorry_id]
    if lorry and lorry.classid == classid then
        return lorry
    end

    if lorry then
        lorry:remove()
    end

    local typeobject = iprototype.queryById(classid)
    local kfs = __gen_keyframes(mask, x, y, toward)
    assert(kfs[1])
    lorry = create_lorry("/pkg/vaststars.resources/" .. typeobject.model, kfs[1].s, kfs[1].r, kfs[1].t, motion_events)
    lorry.classid = classid
    lorries[lorry_id] = lorry

    return lorry
end

local handlers = {}
handlers.endpoint = function(lorry_id, classid, item_classid, item_amount, mask, x, y, toward, offset, progress, maxprogress)
    assert(toward >= 0 or toward <= 1)
    assert(offset >= 0 or offset <= 1)
    -- toward can be 0 or 1, indicating direction towards the station entrance or exit, respectively
    -- two cells represent the straight path for entering or leaving the station
    -- when the offset is 0, it indicates the first cell
    -- when the offset is 1, it indicates the second cell
    -- TODO: station track processing
end

handlers.straight = function(lorry_id, classid, item_classid, item_amount, mask, x, y, toward, offset, progress, maxprogress)
    assert(offset == 0 or offset == 1)
    assert(progress <= maxprogress)

    local lorry = __get_or_create_lorry(lorry_id, classid, mask, x, y, toward)
    lorry:motion_opt("update_keyframes_on_change", mask, x, y, toward)
    lorry:motion_opt("set_ratio", (maxprogress * offset) + (maxprogress - progress), maxprogress * 2)
    lorry:set_item(item_classid, item_amount)
end

handlers.cross = function(lorry_id, classid, item_classid, item_amount, mask, x, y, toward, offset, progress, maxprogress)
    assert(progress <= maxprogress)
    assert(offset == 0)

    local lorry = __get_or_create_lorry(lorry_id, classid, mask, x, y, toward)
    lorry:motion_opt("update_keyframes_on_change", mask, x, y, toward)
    lorry:motion_opt("set_ratio", (maxprogress - progress), maxprogress)
    lorry:set_item(item_classid, item_amount)
end

local function update(lorry_id, classid, item_classid, item_amount, x, y, toward, offset, progress, maxprogress)
    x, y = x * ROAD_TILE_WIDTH_SCALE, y * ROAD_TILE_HEIGHT_SCALE
    local mask = assert(iroad.get(gameplay_core.get_world(), x, y))
    local is_endpoint = (mask & ROADNET_MASK_ENDPOINT == ROADNET_MASK_ENDPOINT)
    assert(toward >= 0 and toward <= 0xf)

    if is_endpoint then
        handlers.endpoint(lorry_id, classid, mask, x, y, toward, offset, progress, maxprogress)
    else
        local prototype_name = mask_to_prototype_name_dir(mask)
        local is_cross_cache = iprototype_cache.get("lorry_manager").is_cross_cache -- TODO: optimize
        if is_cross_cache[prototype_name] then
            handlers.cross(lorry_id, classid, item_classid, item_amount, mask, x, y, toward, offset, progress, maxprogress)
        else
            handlers.straight(lorry_id, classid, item_classid, item_amount, mask, x, y, toward, offset, progress, maxprogress)
        end
    end
end

local function clear()
    for _, obj in pairs(lorries) do
        obj:remove()
    end
    lorries = {}
end

return {
    update = update,
    clear = clear,
}