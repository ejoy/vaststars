local ecs = ...
local world = ecs.world
local w = world.w

local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local iprototype = require "gameplay.interface.prototype"

local m = ecs.system "roadnet_system"
local iroadnet = ecs.interface "iroadnet"
local road_track = import_package "vaststars.prototype"("road_track")
local hierarchy = require "hierarchy"
local animation = hierarchy.animation
local skeleton = hierarchy.skeleton
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local math3d = require "math3d"

local function _make_track(slots, slot_names, tickcount)
    local mat = {}
    local raw_animation = animation.new_raw_animation()
    local skl = skeleton.build({{name = "root", s = mc.T_ONE, r = mc.T_IDENTITY_QUAT, t = mc.T_ZERO}})
    local len = #slot_names
    assert(len > 1)
    raw_animation:setup(skl, len - 1)
    for idx, slot_name in ipairs(slot_names) do
        raw_animation:push_prekey(
            "root",
            idx - 1,
            slots[slot_name].scene.s,
            slots[slot_name].scene.r,
            slots[slot_name].scene.t
        )
    end
    local ani = raw_animation:build()
    local poseresult = animation.new_pose_result(#skl)
    poseresult:setup(skl)

    local ratio = 0
    local step = 1 / tickcount

    while ratio <= 1.0 do
        poseresult:do_sample(animation.new_sampling_context(1), ani, ratio, 0)
        poseresult:fetch_result()
        mat[#mat+1] = math3d.ref(poseresult:joint(1))
        ratio = ratio + step
    end
    return mat
end

local cache = {}
function m:init_world()
    -- TODO: cache matrix move to prototype?
    for _, typeobject in pairs(iprototype.each_maintype("entity", "road")) do
        local slots = igame_object.get_prefab(typeobject.model).slots
        if not next(slots) then
            goto continue
        end

        assert(typeobject.track)
        local track = assert(road_track[typeobject.track])
        for _, entity_dir in pairs(typeobject.flow_direction) do
            for toward, v in pairs(track) do
                local combine_keys = ("%s:%s:%s"):format(typeobject.name, entity_dir, toward) -- TODO: optimize
                assert(cache[combine_keys] == nil)
                cache[combine_keys] = _make_track(slots, v, typeobject.tickcount)
            end
        end

        ::continue::
    end
end

function iroadnet.offset_matrix(prototype_name, dir, toward, tick)
    local combine_keys = ("%s:%s:%s"):format(prototype_name, dir, toward) -- TODO: optimize
    local mat = assert(cache[combine_keys])
    return assert(mat[tick])
end
