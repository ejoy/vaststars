local itrack = require "engine.track"
local iprototype = require "gameplay.interface.prototype"
local prefab_parse = require("engine.prefab_parser").parse

local road_track = import_package "vaststars.prototype"("road_track")

local RESOURCES_BASE_PATH <const> = "/pkg/vaststars.resources/%s"
local CONSTANTS = import_package "vaststars.prototype".load("roadnet")
local STRAIGHT_TICKCOUNT <const> = CONSTANTS.STRAIGHT_TICKCOUNT
local CROSS_TICKCOUNT <const> = CONSTANTS.CROSS_TICKCOUNT

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

return function()
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

    return {
        cache = cache,
        is_cross_cache = is_cross_cache,
    }
end