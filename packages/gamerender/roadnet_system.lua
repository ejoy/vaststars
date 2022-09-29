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
local MULTIPLE = require("debugger").roadnet_multiple or 1

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
                    if toward <= 0xf then -- see also: enum RoadType
                        local s = ((z >> 2)  + t) % 4 -- high 2 bits is indir
                        local e = ((z & 0x3) + t) % 4 -- low  2 bits is outdir
                        z = s << 2 | e
                    else
                        z = (((z & 0xF) + t) % 4) | 0x10
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
local rc_rid = require("gameplay.interface.roadnet").rc_rid
local iprototype = require "gameplay.interface.prototype"
local vsobject_manager = ecs.require "vsobject_manager"
local objects = require "objects"

local running = true
local roadnet_world
local lorries = {}

local function _get_offset_matrix(x, y, toward, tick)
    local object = assert(objects:coord(x, y))
    local vsobject = assert(vsobject_manager:get(object.id))
    local offset_mat = iroadnet.offset_matrix(object.prototype_name, object.dir, toward, tick)
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
    local p = roadnet_world:path(S, E)
	return roadnet_world:add_line(p), p
end

local function _rc_rid(rc)
    return rc & 0xFFFF
end

local function __init_roadnet()
    local m = {}

    local cross_count = 0
    local straight_road_offset = {}
    for e in gameplay_core.select "road entity:in" do
        local prototype_name = iprototype.queryById(e.entity.prototype).name
        local dir = iprototype.dir_tostring(e.entity.direction)
        local loc = (e.entity.y << 8) | e.entity.x -- see also: get_location(lua_State *L, int idx)
        m[loc] = road_mask(prototype_name, dir)

        if entry_count(prototype_name, dir) == 2 then
            straight_road_offset[#straight_road_offset+1] = {x = e.entity.x, y = e.entity.y, z = 0}
            straight_road_offset[#straight_road_offset+1] = {x = e.entity.x, y = e.entity.y, z = 1}
        end
        if entry_count(prototype_name, dir) >= 3 then
            cross_count = cross_count + 1
        end
    end

    if cross_count <= 0 then
        log.error("no crossing found")
        return
    end

    local STRAIGHT_TICKCOUNT <const> = 10
    local WAIT_TICKCOUNT <const> = 10
    local CROSS_TICKCOUNT <const> = 20

    local rnworld = create_roadnet(m, function(lorry_id, is_cross, x, y, z, tick)
        local ti, toward
        if is_cross then
            if z <= 0xf then
                ti = (CROSS_TICKCOUNT - tick)
            else
                ti = (WAIT_TICKCOUNT - tick)
            end
            toward = z
        else
            local pos
            pos, toward = z & 0x0F, (z >> 4) & 0x0F -- pos: [0, 1], toward: [0, 1], tick: [0, (STRAIGHT_TICKCOUNT - 1)]
            ti = pos * STRAIGHT_TICKCOUNT + (STRAIGHT_TICKCOUNT - tick)
        end

        local mat = _get_offset_matrix(x, y, toward, ti)
        local game_object = assert(lorries[lorry_id]).game_object
        game_object:send("obj_motion", "set_srt_matrix", mat)
    end)

    --
    straight_road_offset = _shuffle(straight_road_offset)

    while #straight_road_offset >= 2 do
        local len = #straight_road_offset
        local c1 = straight_road_offset[len]
        local S  = c1.x | (c1.y << 8) | (c1.z << 16)
        local c2 = straight_road_offset[len - 1]
        local E  = c2.x | (c2.y << 8) | (c2.z << 16)

        local rc1, rc2 = rnworld.road_coord[S], rnworld.road_coord[E]
        local roadid1, roadid2 = _rc_rid(rc1), _rc_rid(rc2)

        if roadid1 == roadid2 then -- TODO: avoid two endpoins are on the same road
            straight_road_offset[len] = nil
            straight_road_offset = _shuffle(straight_road_offset)
            goto continue
        end

        if rnworld.cworld:prev_roadid(roadid1) == rnworld.cworld:next_roadid(roadid1) then -- TODO: avoid two endpoins are on the same road (U-turn)
            straight_road_offset[len] = nil
            straight_road_offset = _shuffle(straight_road_offset)
            goto continue
        end

        if rnworld.cworld:prev_roadid(roadid2) == rnworld.cworld:next_roadid(roadid2) then -- TODO: avoid two endpoins are on the same road (U-turn)
            straight_road_offset[len] = nil
            straight_road_offset = _shuffle(straight_road_offset)
            goto continue
        end

        local from, to = rnworld.road_coord[S], rnworld.road_coord[E] -- TODO： avoid two endpoins are on the same road (from == to)
        from = rnworld.cworld:next_roadid(from) or rc_rid(from)
        to = rnworld.cworld:next_roadid(to) or rc_rid(to)
        if from == to then
            straight_road_offset[len] = nil
            straight_road_offset = _shuffle(straight_road_offset)
            goto continue
        end

        local line_id, line = __add_line(rnworld, S, E)
        if line_id then
            local lorry_id = rnworld:add_lorry(line_id, S, E)
            if lorry_id then
                local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
                local COLOR_INVALID <const> = math3d.constant "null"
                local offset_mat = _get_offset_matrix(c1.x, c1.y, (c1.z >> 4) & 0xF, (STRAIGHT_TICKCOUNT * (c1.z & 0xF)) + 1 )
                local s, r, t = math3d.srt(offset_mat)

                assert(lorries[lorry_id] == nil)
                lorries[lorry_id] = { game_object = igame_object.create({
                        prefab = "prefabs/lorry-1.prefab",
                        effect = nil,
                        group_id = 0, -- TODO: change group_id when lorry is moving to the new road block?
                        state = "opaque",
                        color = COLOR_INVALID,
                        srt = {s = s, r = r, t = t},
                    }),
                    x = c1.x, y = c1.y,
                }
                log.info(("lorry_id: %d, line_id: %d, (%s) from(%d,%d,%d) to(%d,%d,%d)"):format(lorry_id, line_id, line, c1.x, c1.y, c1.z, c2.x, c2.y, c2.z))
            end
        end

        straight_road_offset[len] = nil
        straight_road_offset[len - 1] = nil
        break -- TODO
        ::continue::
    end

    return rnworld
end

-- TODO: remove temporary codes below
function m:update_world()
    for _, cmd in roadnet_test_mb:unpack() do
        if cmd == "build" then
            for _, v in pairs(lorries) do
                v.game_object:remove()
            end
            lorries = {}
            roadnet_world = __init_roadnet()
        elseif cmd == "clean" then
            for _, v in pairs(lorries) do
                v.game_object:remove()
            end
            lorries = {}
            roadnet_world = nil
        elseif cmd == "pause" then
            running = not running
        elseif cmd == "debug" then
            local call = require("debugger").call
            call("roadnet", lorries)
        elseif cmd == "reset_multiple" then
            MULTIPLE = 1
        elseif cmd == "set_multiple" then
            MULTIPLE = MULTIPLE + 100
            print("MULTIPLE: " .. MULTIPLE)
        end
    end

    if gameplay_core.world_update and roadnet_world and running then
        for _ = 1, MULTIPLE do
            roadnet_world:update()
        end
    end
end

function iroadnet.offset_matrix(prototype_name, dir, toward, tick)
    if not next(cache) then
        _make_cache()
    end
    local combine_keys = ("%s:%s:%s"):format(prototype_name, dir, toward) -- TODO: optimize
    local mat = assert(cache[combine_keys])
    return assert(mat[tick])
end

function iroadnet.clean()
    for _, v in pairs(lorries) do
        v.game_object:remove()
    end
    lorries = {}
    roadnet_world = nil
end
