local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local lorries = {}
local iprototype = require "gameplay.interface.prototype"
local road_track = import_package "vaststars.prototype"("road_track")
local iterrain = ecs.require "terrain"
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local itrack = ecs.require "engine.track"
local create_lorry = ecs.require "lorry"
local global = require "global"
local iroadnet_converter = require "roadnet_converter"
local RESOURCES_BASE_PATH <const> = "/pkg/vaststars.resources/%s"
local gameplay_core = require "gameplay.core"
local prefab_parse = require("engine.prefab_parser").parse

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

local DIRECTION <const> = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
}

local cache = {}
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
            local tickcount = is_cross and CROSS_TICKCOUNT or STRAIGHT_TICKCOUNT
            for toward, slot_names in pairs(track) do
                local z = toward
                if is_cross then
                    assert(toward <= 0xf) -- see also: enum RoadType
                    local s = ((z >> 2)  + t) % 4 -- high 2 bits is indir
                    local e = ((z & 0x3) + t) % 4 -- low  2 bits is outdir
                    z = s << 2 | e
                else
                    z = (z + DIRECTION[entity_dir])%4
                end

                local combine_keys = ("%s:%s:%s"):format(typeobject.name, entity_dir, z) -- TODO: optimize
                -- assert(cache[combine_keys] == nil)
                cache[combine_keys] = itrack.make_track(slots, slot_names, tickcount)
            end
        end

        ::continue::
    end
end

local function offset_matrix(prototype_name, dir, toward, tick)
    local combine_keys = ("%s:%s:%s"):format(prototype_name, dir, toward) -- TODO: optimize
    local mat = cache[combine_keys]
    if not mat then
        return
    end
    if not mat[tick] then
        return
    end
    return assert(mat[tick])
end

local function _get_offset_matrix(is_cross_flag, x, y, toward, tick)
    local coord = iprototype.packcoord(x, y)
    if not global.roadnet[coord] then
        return
    end
    local mask = assert(global.roadnet[coord])
    local prototype_name, dir = iroadnet_converter.mask_to_prototype_name_dir(mask)
    local matrix = math3d.matrix {t = iterrain:get_position_by_coord(x, y, 1, 1), r = ROTATORS[dir]}
    local is_cross = #iprototype.queryByName(prototype_name).crossing.connections > 2

    if not is_cross_flag then
        if is_cross then
            local REVERSE <const> = {
                [0] = 2,
                [1] = 3,
                [2] = 0,
                [3] = 1,
            }
            toward = toward << 2 | REVERSE[toward]
        else
            local mapping = {
                [0] = DIRECTION.W, -- left
                [1] = DIRECTION.N, -- top
                [2] = DIRECTION.E, -- right
                [3] = DIRECTION.S, -- bottom
            }
            toward = mapping[toward]
        end
    end

    local offset_mat = offset_matrix(prototype_name, dir, toward, tick)
    if not offset_mat then
        return
    end
    local s, r, t = math3d.srt(math3d.mul(matrix, offset_mat))
    t = math3d.set_index(t, 2, 0.0)
    return math3d.ref(math3d.matrix {s = s, r = r, t = t})
end


local ims = ecs.import.interface "ant.motion_sampler|imotion_sampler"
local g

local function update(lorry_id, is_cross, x, y, z, tick)
    if not g then
        g = ims.sampler_group()
        g:enable "view_visible"
        g:enable "scene_update"
    end
    local ti, toward
    if is_cross then
        assert(z <= 0xf)
        ti = (CROSS_TICKCOUNT - tick)
        toward = z
    else
        local pos
        pos, toward = z & 0x0F, (z >> 4) & 0x0F -- pos: [0, 1], toward: [0, 1], tick: [0, (STRAIGHT_TICKCOUNT - 1)]
        -- assert(pos == 0 and pos == 1) -- TODO: remove assert
        ti = STRAIGHT_TICKCOUNT - tick
    end
    ti = ti + 1 -- offset matrix start from 1

    if not lorries[lorry_id] then
        local offset_mat = _get_offset_matrix(is_cross, x, y, toward, ti)
        if offset_mat then
            local s, r, t = math3d.srt(offset_mat) -- TODO: optimize
            lorries[lorry_id] = create_lorry("/pkg/vaststars.resources/prefabs/lorry-1.prefab", s, r, t)
        end
    else
        local mat = _get_offset_matrix(is_cross, x, y, toward, ti)
        if mat then
            local obj = assert(lorries[lorry_id])
            obj:set_mat(mat)
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