local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local lorries = {}
local iprototype = require "gameplay.interface.prototype"
local packcoord = iprototype.packcoord
local iterrain = ecs.require "terrain"
local create_lorry = ecs.require "lorry"
local global = require "global"
local iroadnet_converter = require "roadnet_converter"
local gameplay_core = require "gameplay.core"
local iprototype_cache = require "gameplay.prototype_cache.init"

local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local UPS <const> = require("gameplay.interface.constant").UPS

local CONSTANTS = gameplay_core.get_world():roadnet_constants()
local STRAIGHT_TICKCOUNT <const> = CONSTANTS.kTime
local CROSS_TICKCOUNT <const> = CONSTANTS.kCrossTime

local function __get_offset_matrix(prototype_name, dir, toward, tick)
    local combine_keys = ("%s:%s:%s"):format(prototype_name, dir, toward) -- TODO: optimize
    local cache = iprototype_cache.get("lorry_manager").cache
    local mat = assert(cache[combine_keys])
    return assert(mat[tick])
end

local function __is_endpoint(m)
    return (m & (1 << 4)) == (1 << 4) -- see also: isEndpoint()
end

local function __create_or_move_lorry(lorry_id, s, r, t, duration)
    s, r, t = math3d.ref(s), math3d.ref(r), math3d.ref(t)
    if not lorries[lorry_id] then
        lorries[lorry_id] = create_lorry("/pkg/vaststars.resources/prefabs/lorry-1.prefab", s, r, t)
    else
        local obj = lorries[lorry_id]
        obj:set_target(s, r, t, duration)
    end
end

local handlers = {}
handlers.endpoint = function(lorry_id, mask, x, y, z, tick)
    local ti = STRAIGHT_TICKCOUNT - tick
    local wait, toward, offset = (z >> 5) & 0x01, (z >> 4) & 0x01, z & 0x0F
    assert(wait >= 0 or wait <= 1)
    assert(toward >= 0 or toward <= 1)
    assert(offset >= 0 or offset <= 1)
    -- toward can be 0 or 1, indicating direction towards the station entrance or exit, respectively
    -- two cells represent the straight path for entering or leaving the station
    -- when the offset is 0, it indicates the first cell
    -- when the offset is 1, it indicates the second cell
    -- TODO: station track processing

    -- in the waiting area, do nothing
    if wait == 1 then
        return
    end
end

handlers.straight = function(lorry_id, mask, x, y, z, tick)
    local wait, toward, offset = (z >> 5) & 0x01, (z >> 4) & 0x01, z & 0x0F
    assert(wait >= 0 or wait <= 1)
    assert(toward >= 0 or toward <= 1)
    assert(offset >= 0 or offset <= 1)
    local ti = STRAIGHT_TICKCOUNT - tick + (STRAIGHT_TICKCOUNT * offset)
    ti = ti + 1 -- offset matrix start from 1, [1, 2 * STRAIGHT_TICKCOUNT]

    -- in the waiting area at the intersection, do nothing
    if wait == 1 then
        return
    end

    local prototype_name, dir = iroadnet_converter.mask_to_prototype_name_dir(mask)
    local road_matrix = math3d.matrix {t = iterrain:get_position_by_coord(x, y, 1, 1), r = ROTATORS[dir]}
    local typeobject = iprototype.queryByName(prototype_name)

    -- regarding the special optimization for straight roads
    -- directly instruct the __create_or_move_lorry function to notify the lorry to arrive at the position after STRAIGHT_TICKCOUNT ticks
    if typeobject.track == "I" then
        if not lorries[lorry_id] or ti == 1 or ti == STRAIGHT_TICKCOUNT + 1 then
            local mat = __get_offset_matrix(prototype_name, dir, toward, ti + STRAIGHT_TICKCOUNT - 1)
            local s, r, t = math3d.srt(math3d.mul(road_matrix, mat))
            t = math3d.set_index(t, 2, 0.0)
            __create_or_move_lorry(lorry_id, s, r, t, 1000 / UPS * STRAIGHT_TICKCOUNT)
        end
        return
    end

    local mat = __get_offset_matrix(prototype_name, dir, toward, ti)
    local s, r, t = math3d.srt(math3d.mul(road_matrix, mat))
    t = math3d.set_index(t, 2, 0.0)
    __create_or_move_lorry(lorry_id, s, r, t, 1000 / UPS)
end

handlers.cross = function(lorry_id, mask, x, y, z, tick)
    local toward = z
    local ti = CROSS_TICKCOUNT - tick
    ti = ti + 1 -- offset matrix start from 1

    local prototype_name, dir = iroadnet_converter.mask_to_prototype_name_dir(mask)
    local road_matrix = math3d.matrix {t = iterrain:get_position_by_coord(x, y, 1, 1), r = ROTATORS[dir]}
    local mat = __get_offset_matrix(prototype_name, dir, toward, ti)
    local s, r, t = math3d.srt(math3d.mul(road_matrix, mat))
    t = math3d.set_index(t, 2, 0.0)
    __create_or_move_lorry(lorry_id, s, r, t, 1000 / UPS)
end

local function update(lorry_id, x, y, z, tick)
    local mask = assert(global.roadnet[packcoord(x, y)])
    local is_endpoint = __is_endpoint(mask)

    if is_endpoint then
        handlers.endpoint(lorry_id, mask, x, y, z, tick)
    else
        local prototype_name = iroadnet_converter.mask_to_prototype_name_dir(mask)
        local is_cross_cache = iprototype_cache.get("lorry_manager").is_cross_cache
        if is_cross_cache[prototype_name] then
            handlers.cross(lorry_id, mask, x, y, z, tick)
        else
            handlers.straight(lorry_id, mask, x, y, z, tick)
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