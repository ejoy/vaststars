local iprototype = require "gameplay.interface.prototype"
local prefab_slots = require("engine.prefab_parser").slots
local prefab_root = require("engine.prefab_parser").root
local road_track = import_package "vaststars.prototype"("road_track")
local math3d = require "math3d"

local RESOURCES_BASE_PATH <const> = "/pkg/vaststars.resources/%s"

local function rotate_dir(dir, entity_dir)
    local t = iprototype.dir_tonumber(entity_dir) - iprototype.dir_tonumber('N')
    return (dir + t) % 4
end

return function()
    local mt = {}
    mt.__index = function (t, k)
        t[k] = setmetatable({}, mt)
        return t[k]
    end

    local cache = setmetatable({}, mt)
    local is_cross_cache = {}
    do
        for _, typeobject in pairs(iprototype.each_type("building", "road")) do
            local slots = prefab_slots(RESOURCES_BASE_PATH:format(typeobject.model))
            if not next(slots) then
                goto continue
            end

            assert(typeobject.track)

            local is_cross = #typeobject.crossing.connections > 2
            is_cross_cache[typeobject.name] = is_cross

            local track = assert(road_track[typeobject.track])
            for _, entity_dir in pairs(typeobject.building_direction) do
                for toward, slot_names in pairs(track) do
                    local z
                    if is_cross then
                        assert(toward <= 0xf) -- see also: enum RoadType
                        local s = rotate_dir(toward >> 0x2, entity_dir) -- high 2 bits is indir
                        local e = rotate_dir(toward &  0x3, entity_dir) -- low  2 bits is outdir
                        z = s << 2 | e
                    else
                        z = toward
                    end

                    assert(rawget(cache[typeobject.name][entity_dir], z) == nil)

                    local root_srt = prefab_root(RESOURCES_BASE_PATH:format(typeobject.model)).data.scene

                    local track_srts = {}
                    for _, slot_name in ipairs(slot_names) do
                        local slot_srt = {
                            s = math3d.vector(slots[slot_name].scene.s),
                            r = math3d.quaternion(slots[slot_name].scene.r),
                            t = math3d.set_index(math3d.vector(slots[slot_name].scene.t), 2, 0),
                        }
                        local mat = math3d.mul(math3d.matrix(root_srt), math3d.matrix(slot_srt))
                        local s, r, t = math3d.srt(mat)

                        track_srts[#track_srts+1] = {
                            s = math3d.ref(s),
                            r = math3d.ref(r),
                            t = math3d.ref(t),
                        }
                    end
                    cache[typeobject.name][entity_dir][z] = track_srts
                end
            end
            ::continue::
        end
    end

    return {
        cache = cache,
        is_cross_cache = is_cross_cache,
    }
end