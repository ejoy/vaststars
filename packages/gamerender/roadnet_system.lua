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
local roadnet_test_mb = world:sub {"roadnet"}
local is_cross = require("gameplay.interface.roadnet").is_cross
local entry_count = require("gameplay.interface.roadnet").entry_count

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
            local t = iprototype.dir_tonumber(entity_dir) - iprototype.dir_tonumber('N')

            for toward, slot_names in pairs(track) do
                local z = toward
                if is_cross(typeobject.name, entity_dir) then
                    if toward <= 0xf then -- see also: enum RoadType
                        local s = ((z >> 2)  + t) % 4 -- high 2 bits is indir
                        local e = ((z & 0x3) + t) % 4 -- low  2 bits is outdir
                        z = s << 2 | e
                    else
                        z = (((z & 0xF) + t) % 4) | 0x10
                    end
                else
                    if entity_dir == "S" or entity_dir == "W" then -- see also: get_direction_straight(m, z)
                        z = (z + 1) % 2
                    else
                        z = toward
                    end
                end

                local combine_keys = ("%s:%s:%s"):format(typeobject.name, entity_dir, z) -- TODO: optimize
                assert(cache[combine_keys] == nil)
                cache[combine_keys] = _make_track(slots, slot_names, typeobject.tickcount)
            end
        end

        ::continue::
    end
end

-- TODO: remove temporary codes below
local gameplay_core = require "gameplay.core"
local create_roadnet = require("gameplay.interface.roadnet").create
local road_mask = require("gameplay.interface.roadnet").road_mask
local iprototype = require "gameplay.interface.prototype"
local vsobject_manager = ecs.require "vsobject_manager"
local objects = require "objects"

local roadnet_world
local lorries = {}

local function _get_offset_matrix_straight(x, y, toward, tick)
    local object = assert(objects:coord(x, y))
    local vsobject = assert(vsobject_manager:get(object.id))
    local offset_mat = iroadnet.offset_matrix(object.prototype_name, object.dir, toward, tick)
    return math3d.ref(math3d.mul(vsobject:get_matrix(), offset_mat))
end

local function _get_offset_matrix_cross(x, y, z, tick)
    local object = assert(objects:coord(x, y))
    local vsobject = assert(vsobject_manager:get(object.id))
    local offset_mat = iroadnet.offset_matrix(object.prototype_name, object.dir, z, tick)
    return math3d.ref(math3d.mul(vsobject:get_matrix(), offset_mat))
end

local function _shuffle(t)
	local random = math.random
	local len = #t
	for i = 1, len - 1 do
		local rnd = random(i, len)
		t[i], t[rnd] = t[rnd], t[i]
	end
	return t
end

local function __add_line(roadnet_world, S, E)
	local p1 = roadnet_world:bfs(S, E)
	local p2 = roadnet_world:bfs(E, S)
    if p1 == nil or p2 == nil then -- TODO: optimize
        return
    end
	return roadnet_world:add_line(p1 .. p2)
end

local function __init_roadnet()
    local m = {}
    local cross_coord = {}
    for e in gameplay_core.select "road entity:in" do
        local prototype_name = iprototype.queryById(e.entity.prototype).name
        local dir = iprototype.dir_tostring(e.entity.direction)
        local loc = (e.entity.y << 8) | e.entity.x -- see also: get_location(lua_State *L, int idx)
        m[loc] = road_mask(prototype_name, dir)

        if entry_count(prototype_name, dir) == 2 then
            cross_coord[#cross_coord+1] = {x = e.entity.x, y = e.entity.y, z = 0}
            cross_coord[#cross_coord+1] = {x = e.entity.x, y = e.entity.y, z = 1}
        end
    end

    local STRAIGHT_TICKCOUNT <const> = 10
    local WAIT_TICKCOUNT <const> = 10
    local CROSS_TICKCOUNT <const> = 20

    roadnet_world = create_roadnet(m, function(lorry_id, is_cross, x, y, z, tick)
        local lorry = assert(lorries[lorry_id])
        local offset_mat, ti
        if is_cross then
            if z <= 0xf then
                ti = (CROSS_TICKCOUNT - tick)
            else
                ti = (WAIT_TICKCOUNT - tick)
            end
            offset_mat = _get_offset_matrix_cross(x, y, z, ti)
        else
            local pos, toward = z & 0x0F, (z >> 4) & 0x0F -- pos: 0-1, toward: 0-1, tick: 0-(STRAIGHT_TICKCOUNT - 1)
            ti = pos * STRAIGHT_TICKCOUNT + (STRAIGHT_TICKCOUNT - tick)
            offset_mat = _get_offset_matrix_straight(x, y, toward, ti)
        end

        local s, r, t = math3d.srt(offset_mat)
        offset_mat = math3d.ref(math3d.matrix {s = s, r = r, t = t})
        lorry:send("obj_motion", "set_srt_matrix", offset_mat)
    end)

    --
    cross_coord = _shuffle(cross_coord)
    while #cross_coord >= 2 do
        local len = #cross_coord
        local c1 = cross_coord[len]
        local S  = c1.x | (c1.y << 8) | (c1.z << 16)
        local c2 = cross_coord[len - 1]
        local E  = c2.x | (c2.y << 8) | (c2.z << 16)

        local line_id = __add_line(roadnet_world, S, E)
        if line_id then
            local lorry_id = roadnet_world:add_lorry(line_id, 0, c1.x, c1.y, c1.z & 0x0F)
            if lorry_id then
                local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
                local COLOR_INVALID <const> = math3d.constant "null"
                local offset_mat = _get_offset_matrix_straight(c1.x, c1.y, c1.z & 0x0F, 1) -- first tick is 1
                local s, r, t = math3d.srt(offset_mat)

                assert(lorries[lorry_id] == nil)
                lorries[lorry_id] = igame_object.create {
                    prefab = "prefabs/lorry-1.prefab",
                    effect = nil,
                    group_id = 0,
                    state = "opaque",
                    color = COLOR_INVALID,
                    srt = {s = s, r = r, t = t},
                }
            end 
        end

        cross_coord[len] = nil
        cross_coord[len - 1] = nil
    end

    return roadnet_world
end

-- TODO: remove temporary codes below
function m:update_world()
    for _ in roadnet_test_mb:unpack() do
        for _, lorry in pairs(lorries) do
            lorry:remove()
        end
        lorries = {}

        roadnet_world = __init_roadnet()
    end

    if gameplay_core.world_update and roadnet_world then
        roadnet_world:update()
    end
end

function iroadnet.offset_matrix(prototype_name, dir, toward, tick)
    local combine_keys = ("%s:%s:%s"):format(prototype_name, dir, toward) -- TODO: optimize
    local mat = assert(cache[combine_keys])
    return assert(mat[tick])
end
