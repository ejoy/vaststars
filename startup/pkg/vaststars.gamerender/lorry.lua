local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local lorries = {}
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local COLOR_INVALID <const> = math3d.constant "null"
local iprototype = require "gameplay.interface.prototype"
local road_track = import_package "vaststars.prototype"("road_track")
local hierarchy = require "hierarchy"
local animation = hierarchy.animation
local skeleton = hierarchy.skeleton
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local iroadnet = ecs.require "roadnet"
local iterrain = ecs.require "terrain"
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"

local STRAIGHT_TICKCOUNT <const> = 10
local CROSS_TICKCOUNT <const> = 20

local is_cross; do
    local mt = {}
    function mt:__index(k)
        local v = {}
        rawset(self, k, v)
        return v
    end
    local prototype_bits = setmetatable({}, mt) -- = [prototype][direction] = bits
    local bits_prototype = setmetatable({}, mt)

    local mapping = {
        W = 0, -- left
        N = 1, -- top
        E = 2, -- right
        S = 3, -- bottom
    }

    -- every 2 bits represent one direction of a road, 00 means nothing, 01 means road, 10 means roadside, total 8 bits represent 4 directions
    for _, typeobject in pairs(iprototype.each_maintype("entity", "road")) do
        for _, entity_dir in pairs(typeobject.flow_direction) do
            local bits = 0
            local c = 0

            local connections = typeobject.crossing.connections
            for _, connection in ipairs(connections) do
                local dir = assert(mapping[iprototype.rotate_dir(connection.position[3], entity_dir)])
                local value
                if connection.roadside then
                    value = 2
                else
                    value = 1
                end
                c = c + 1
                bits = bits | (value << (dir * 2))
            end

            assert(prototype_bits[typeobject.name][entity_dir] == nil)
            prototype_bits[typeobject.name][entity_dir] = {bits = bits, is_cross = (c >= 3), c = c}
            bits_prototype[bits] = {name = typeobject.name, dir = entity_dir}
        end
    end

    function is_cross(prototype_name, dir)
        return assert(prototype_bits[prototype_name][dir]).is_cross
    end
end

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

local DIRECTION <const> = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
}

local cache = {}
local function _make_cache()
    -- TODO: cache matrix move to prototype?
    for _, typeobject in pairs(iprototype.each_maintype("entity", "road")) do
        local slots = igame_object.get_prefab(typeobject.model).slots
        if not next(slots) then
            goto continue
        end

        assert(typeobject.track)
        local track = assert(road_track[typeobject.track])
        for _, entity_dir in pairs(typeobject.flow_direction) do
            local t = iprototype.dir_tonumber(entity_dir) - iprototype.dir_tonumber('N')

            for toward, slot_names in pairs(track) do
                local z = toward
                if is_cross(typeobject.name, entity_dir) then
                    assert(toward <= 0xf) -- see also: enum RoadType
                    local s = ((z >> 2)  + t) % 4 -- high 2 bits is indir
                    local e = ((z & 0x3) + t) % 4 -- low  2 bits is outdir
                    z = s << 2 | e
                else
                    z = (z + DIRECTION[entity_dir])%4
                end

                local combine_keys = ("%s:%s:%s"):format(typeobject.name, entity_dir, z) -- TODO: optimize
                -- assert(cache[combine_keys] == nil)
                cache[combine_keys] = _make_track(slots, slot_names, typeobject.tickcount)
            end
        end

        ::continue::
    end
end

local function offset_matrix(prototype_name, dir, toward, tick)
    if not next(cache) then
        _make_cache()
    end
    local combine_keys = ("%s:%s:%s"):format(prototype_name, dir, toward) -- TODO: optimize
    local mat = assert(cache[combine_keys])
    return assert(mat[tick])
end

local function _get_offset_matrix(is_cross_flag, x, y, toward, tick)
    local _, mask = iroadnet.editor_get(x, y)
    assert(mask)

    local prototype_name, dir = iroadnet.get_prototype_name(0, mask) -- TODO
    local matrix = math3d.matrix {t = iterrain:get_position_by_coord(x, y, 1, 1), r = ROTATORS[dir]}

    if not is_cross_flag then
        if is_cross(prototype_name, dir) then
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
    local s, r, t = math3d.srt(math3d.mul(matrix, offset_mat))
    t = math3d.set_index(t, 2, 0.0)
    return math3d.ref(math3d.matrix {s = s, r = r, t = t})
end


local ims = ecs.import.interface "ant.motion_sampler|imotion_sampler"
local g

return function(lorry_id, is_cross, x, y, z, tick)
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
        ti = pos * STRAIGHT_TICKCOUNT + (STRAIGHT_TICKCOUNT - tick)
    end
    ti = ti + 1 -- offset matrix start from 1

    if not lorries[lorry_id] then
        local offset_mat = _get_offset_matrix(is_cross, x, y, toward, ti)
        local s, r, t = math3d.srt(offset_mat) -- TODO: optimize

        local events = {}
        events["set_target"] = function(_, e, mat)
            local s, r, t = math3d.srt(mat)
            ims.set_target(e, s, r, t, 20)
        end
        local obj = ientity_object.create(g:create_entity {
            policy = {
                "ant.scene|scene_object",
                "ant.motion_sampler|motion_sampler",
                "ant.general|name",
            },
            data = {
                scene = {
                    s = s,
                    r = r,
                    t = t,
                },
                name = "motion_sampler",
            }
        }, events)

        lorries[lorry_id] = obj

        local p = g:create_instance("/pkg/vaststars.resources/prefabs/lorry-1.prefab", obj.id)
        p.on_ready = function (e)
        end
        world:create_object(p)
    else
        local mat = _get_offset_matrix(is_cross, x, y, toward, ti)
        local obj = assert(lorries[lorry_id])
        obj:send("set_target", mat)
    end
end
