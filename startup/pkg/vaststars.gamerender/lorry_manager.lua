local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local lorries = {}
local iprototype = require "gameplay.interface.prototype"
local packcoord = iprototype.packcoord
local road_track = import_package "vaststars.prototype"("road_track")
local iterrain = ecs.require "terrain"
local itrack = ecs.require "engine.track"
local create_lorry = ecs.require "lorry"
local global = require "global"
local iroadnet_converter = require "roadnet_converter"
local gameplay_core = require "gameplay.core"
local prefab_parse = require("engine.prefab_parser").parse

local RESOURCES_BASE_PATH <const> = "/pkg/vaststars.resources/%s"
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS

local CONSTANTS = gameplay_core.get_world():roadnet_constants()
local STRAIGHT_TICKCOUNT <const> = CONSTANTS.kTime
local CROSS_TICKCOUNT <const> = CONSTANTS.kCrossTime

local function __prefab_slots(prefab)
    local res = {}
    local t = prefab_parse(RESOURCES_BASE_PATH:format(prefab))
    for _, v in ipairs(t) do
        if v.data.slot then
            res[v.data.name] = v.data
        end
    end
    return res
end

local cache = {}
local is_cross_cache = {}
do
    for _, typeobject in pairs(iprototype.each_type("building", "road")) do
        local slots = __prefab_slots(typeobject.model)
        if not next(slots) then
            goto continue
        end

        assert(typeobject.track)
        local is_cross = #typeobject.crossing.connections > 2
        local track = assert(road_track[typeobject.track])
        for _, entity_dir in pairs(typeobject.flow_direction) do
            local t = iprototype.dir_tonumber(entity_dir) - iprototype.dir_tonumber('N')
            local tickcount = is_cross and CROSS_TICKCOUNT or (STRAIGHT_TICKCOUNT * 2)
            for toward, slot_names in pairs(track) do
                local z = toward
                if is_cross then
                    assert(toward <= 0xf) -- see also: enum RoadType
                    local s = ((z >> 2)  + t) % 4 -- high 2 bits is indir
                    local e = ((z & 0x3) + t) % 4 -- low  2 bits is outdir
                    z = s << 2 | e
                else
                    z = toward
                end

                local combine_keys = ("%s:%s:%s"):format(typeobject.name, entity_dir, z) -- TODO: optimize
                assert(cache[combine_keys] == nil)
                cache[combine_keys] = itrack.make_track(slots, slot_names, tickcount)
            end
        end

        is_cross_cache[typeobject.name] = #typeobject.crossing.connections > 2
        ::continue::
    end
end

local function __get_offset_matrix(prototype_name, dir, toward, tick)
    local combine_keys = ("%s:%s:%s"):format(prototype_name, dir, toward) -- TODO: optimize
    local mat = assert(cache[combine_keys])
    return assert(mat[tick])
end

local function __is_endpoint(m)
    return (m & (1 << 4)) == (1 << 4) -- see also: isEndpoint()
end

local handlers = {}
handlers.endpoint = function(x, y, z, tick)
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
end

handlers.straight = function(prototype_name, dir, z, tick)
    local wait, toward, offset = (z >> 5) & 0x01, (z >> 4) & 0x01, z & 0x0F
    assert(wait >= 0 or wait <= 1)
    assert(toward >= 0 or toward <= 1)
    assert(offset >= 0 or offset <= 1)
    local ti = STRAIGHT_TICKCOUNT - tick + (STRAIGHT_TICKCOUNT * offset)
    ti = ti + 1 -- offset matrix start from 1

    -- in the waiting area at the intersection, do nothing
    if wait == 1 then
        return
    end

    return __get_offset_matrix(prototype_name, dir, toward, ti)
end

handlers.cross = function(prototype_name, dir, z, tick)
    local toward = z
    local ti = CROSS_TICKCOUNT - tick
    ti = ti + 1 -- offset matrix start from 1

    return __get_offset_matrix(prototype_name, dir, toward, ti)
end

local function update(lorry_id, x, y, z, tick)
    local mask = assert(global.roadnet[packcoord(x, y)])
    local is_endpoint = __is_endpoint(mask)
    local s, r, t

    if is_endpoint then
        local mat = handlers.endpoint(x, y, z, tick)
        if not mat then
            return
        end
    else
        local prototype_name, dir = iroadnet_converter.mask_to_prototype_name_dir(mask)
        local road_matrix = math3d.matrix {t = iterrain:get_position_by_coord(x, y, 1, 1), r = ROTATORS[dir]}
        local mat
        if is_cross_cache[prototype_name] then
            mat = handlers.cross(prototype_name, dir, z, tick)
        else
            mat = handlers.straight(prototype_name, dir, z, tick)
        end
        if not mat then
            return
        end
        s, r, t = math3d.srt(math3d.mul(road_matrix, mat))
        t = math3d.set_index(t, 2, 0.0)
    end

    if not lorries[lorry_id] then
        lorries[lorry_id] = create_lorry("/pkg/vaststars.resources/prefabs/lorry-1.prefab", s, r, t)
    else
        local obj = assert(lorries[lorry_id])
        obj:set_mat(math3d.ref(math3d.matrix {s = s, r = r, t = t}))
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