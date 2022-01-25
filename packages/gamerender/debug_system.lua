local ecs = ...
local world = ecs.world
local w = world.w

---
local print_srt; do
    local math3d = require "math3d"
    local iom = ecs.import.interface "ant.objcontroller|iobj_motion"

    function print_srt(e)
        print("print_str", tostring(e))
        print("position", table.concat(math3d.tovalue(iom.get_position(e)), ","))
        print("rotation", table.concat(math3d.tovalue(iom.get_rotation(e)), ","))
    end
end

local ltask = require "ltask"
local ltask_now = ltask.now
local function get_current()
    local _, now = ltask_now()
    return now * 10
end

local create_queue = import_package("vaststars.utility").queue
--------------------------------------------------------
local update_fps, get_fps do
    local max_cache_milsec <const> = 10000
    local max_cache_sec <const> = max_cache_milsec / 1000
    local frames = create_queue()

    function update_fps()
        local current = get_current()
        frames:push(current)

        local h = frames:gethead()
        while h and current - h > max_cache_milsec do
            frames:pop()
            h = frames:gethead()
        end
    end

    function get_fps()
        return (frames:size() / max_cache_sec)
    end
end

local add_entity_count, dec_entity_count, get_entity_count; do
    local c = 0
    function get_entity_count()
        return c
    end

    function add_entity_count()
        c = c + 1
    end

    function dec_entity_count()
        c = c - 1
    end
end

--------------------------------------------------------
--------------------------------------------------------

local debug_sys = ecs.system 'debug_system'
local debug_mb = world:sub {"debug"}
local funcs = {}
local test_funcs = {}

local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local function get_debug_component(debug)
    for game_object in w:select "debug_component:in" do
        if game_object.debug_component == debug then
            return game_object
        end
    end
end

local function get_debug_prefab(debug)
    local game_object = get_debug_component(debug)
    if not game_object then
        -- print(("Can not found debug component `%s`"):format(debug))
        return
    end
    return igame_object.get_prefab_object(game_object)
end

local function get_debug_prefab_object(debug)
    local game_object = get_debug_component(debug)
    if not game_object then
        -- print(("Can not found debug component `%s`"):format(debug))
        return
    end
    return igame_object.get_prefab_object(game_object)
end

local function remove_debug_prefab(debug)
    local prefab = get_debug_prefab_object(debug)
    if prefab then
        prefab:remove()
    end
end

------
-- test animation
funcs[1] = function ()
    local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
    local prefab
    for game_object in w:select "inserter:in" do
        prefab = igame_object.get_prefab_object(game_object)
        prefab:send("play_animation_once", "DownToUp")
    end
end

funcs[2] = function ()
    local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
    local prefab
    for game_object in w:select "inserter:in" do
        prefab = igame_object.get_prefab_object(game_object)
        prefab:send("play_animation_once", "UpToDown")
    end
end

test_funcs[1] = function ()
    local animation_mb = world:sub {"animation"}
    for _, _, action, game_object in animation_mb:unpack() do
        local slot_name <const> = "货物挂点"
        local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
        local prefab = igame_object.get_prefab_object(game_object)
        if action == "play" then
            local sprefab = ecs.create_instance("/pkg/vaststars.resources/rock.prefab")
            sprefab.on_message = function(prefab, cmd)
                if cmd == "remove" then
                    prefab:remove()
                end
            end
            prefab:send("slot_attach", slot_name, world:create_object(prefab))
        elseif action == "stop" then
            prefab:send("slot_detach", slot_name, slot_name)
        end
    end
end

------
funcs[3] = function ()
    local iroad = ecs.import.interface "vaststars.gamerender|iroad"
    local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
    local iprefab_object = ecs.import.interface "vaststars.gamerender|iprefab_object"
    local igameplay_adapter = ecs.import.interface "vaststars.gamerender|igameplay_adapter"

    local t = {
        {{}       , {123,129}},
        {{123,129}, {123,128}},
        {{123,128}, {124,128}},
        {{124,128}, {125,128}},
        {{125,128}, {125,129}},
        {{125,128}, {125,127}},
        {{125,128}, {126,128}},
        {{126,128}, {127,128}},
        {{127,128}, {128,128}},
        {{128,128}, {129,128}},
        {{129,128}, {130,128}},
        {{130,128}, {131,128}},
        {{131,128}, {132,128}},
        {{132,128}, {132,129}},
        {{132,128}, {133,128}},
        {{132,128}, {132,127}},
        {{132,129}, {132,130}},
        {{132,130}, {131,130}},
    }

    for _, v in ipairs(t) do
        if #v[1] > 0 then
            iroad.construct(v[1], v[2])
        else
            iroad.construct(nil,  v[2])
        end
    end

    -- add logistics_center
    local new_prefab = ecs.create_instance(("/pkg/vaststars.resources/%s"):format("logistics_center.prefab"))
    local srt = {
        s = {1.0,1.0,1.0,0.0},
        r = {0.0,0.0,0.0,1.0},
        t = {-50.0,0.0,30.0,1.0},
    }
    iom.set_srt(new_prefab.root, srt.s, srt.r, srt.t)
    local template = {
        policy = {
            "ant.general|name",
        },
        data = {
            name = "",
            area = {3, 3},
            dir = 'N',
            building_type = "logistics_center",
            stop_ani_during_init = true,
            set_road_entry_during_init = true,
            pickup_show_remove = false,
            pickup_show_ui = {url = "route.rml"},
            route_endpoint = true,
            named = true,
            x = 0x7b,
            y = 0x83,
        },
    }
    new_prefab.on_ready = function(game_object, prefab)
        w:sync("area:in x:in y:in", game_object)
        w:sync("scene:in", prefab.root)
        igameplay_adapter.create_entity {
            station = {
                id = prefab.root.scene.id,
                coord = igameplay_adapter.pack_coord(game_object.x, game_object.y + (-1 * (game_object.area[2] // 2)) - 1),
            }
        }
    end
    iprefab_object.create(new_prefab, template)

    -- add logistics_center
    local new_prefab = ecs.create_instance(("/pkg/vaststars.resources/%s"):format("logistics_center.prefab"))
    local srt = {
        s = {1.0,1.0,1.0,0.0},
        r = {0.0,0.0,0.0,1.0},
        t = {30.0,0.0,40.0,1.0},
    }
    iom.set_srt(new_prefab.root, srt.s, srt.r, srt.t)
    local template = {
        policy = {
            "ant.general|name",
        },
        data = {
            name = "",
            area = {3, 3},
            dir = 'N',
            building_type = "logistics_center",
            stop_ani_during_init = true,
            set_road_entry_during_init = true,
            pickup_show_remove = false,
            pickup_show_ui = {url = "route.rml"},
            route_endpoint = true,
            named = true,
            x = 0x83,
            y = 0x84,
        },
    }

    new_prefab.on_ready = function(game_object, prefab)
        w:sync("area:in x:in y:in", game_object)
        w:sync("scene:in", prefab.root)
        igameplay_adapter.create_entity {
            station = {
                id = prefab.root.scene.id,
                coord = igameplay_adapter.pack_coord(game_object.x, game_object.y + (-1 * (game_object.area[2] // 2)) - 1),
            }
        }
    end
    iprefab_object.create(new_prefab, template)
end

-- test track
do
    local function get_endpoint_coord(id)
        for game_object in w:select "route_endpoint:in x:in y:in" do
            local prefab_object = igame_object.get_prefab_object(game_object)
            w:sync("scene:in ", prefab_object.root)
            w:sync("area:in", game_object)
            if prefab_object.root.scene.id == id then
                return {game_object.x, game_object.y + (-1 * (game_object.area[2] // 2)) - 1}
            end
        end
    end

    local function get_road_game_object(coord)
        local x = coord[1]
        local y = coord[2]

        local e = w:singleton("road_entities", "road_entities:in")
        local road_entities = e.road_entities

        assert(road_entities[x])
        assert(road_entities[x][y])
        return road_entities[x][y]
    end

    local config = import_package "vaststars.config"
    local DIRECTION <const> = {
        N = 0,
        E = 1,
        S = 2,
        W = 3,
    }

    local DIRECTION_REV = {}
    for dir, v in pairs(DIRECTION) do
        DIRECTION_REV[v] = dir
    end

    local function get_road_track_slots(road_game_object, indir, outdir)
        local e = w:singleton("road_types", "road_types:in")
        w:sync("x:in y:in", road_game_object)
        local road_type_dir = (e.road_types[road_game_object.x][road_game_object.y])
        local rt = road_type_dir:sub(1, 1)
        local dir = road_type_dir:sub(2, 2)

        indir = (DIRECTION[indir] - DIRECTION[dir]) % 4
        outdir = (DIRECTION[outdir] - DIRECTION[dir]) % 4
        local slot_names = config.road_track[rt][DIRECTION_REV[indir]][DIRECTION_REV[outdir]]

        local t = {}
        for _, v in ipairs(slot_names) do
            t[#t+1] = road_game_object.prefab_slot_cache[v]
        end
        return t
    end

    local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
    local iprefab_object = ecs.import.interface "vaststars.gamerender|iprefab_object"
    local igameplay_adapter = ecs.import.interface "vaststars.gamerender|igameplay_adapter"
    local math3d        = require "math3d"
    local hierarchy = require "hierarchy"
    local animation = hierarchy.animation
    local skeleton = hierarchy.skeleton

    local srts = {}
    local idx = 1
    local run = true
    local last_update_time
    local delta_time

    funcs[4] = function ()
        if next(srts) then
            idx = 1
            last_update_time = nil
            -- srts = {}
            -- run = false
            return
        end

        local endpoint_ids = {}
        for game_object in w:select "route_endpoint:in" do
            local prefab_object = igame_object.get_prefab_object(game_object)
            w:sync("scene:in", prefab_object.root)
            endpoint_ids[#endpoint_ids + 1] = prefab_object.root.scene.id

            if #endpoint_ids >= 2 then
                break
            end
        end

        if #endpoint_ids ~= 2 then
            print(#endpoint_ids, "can not found endpoints")
            return
        end

        local road_path
        if run then
            road_path = igameplay_adapter.world_caller("road_path", endpoint_ids[1], endpoint_ids[2])
        else
            road_path = igameplay_adapter.world_caller("road_path", endpoint_ids[2], endpoint_ids[1])
        end
        assert(road_path)

        local result = {{coord = get_endpoint_coord(endpoint_ids[1]), indir = 'N'}}
        for _, dir in ipairs(road_path) do
            local x = result[#result].coord[1]
            local y = result[#result].coord[2]
            local indir
            if dir == 0 then
                x = x + 1
                indir = 'W'
            elseif dir == 1 then
                x = x - 1
                indir = 'E'
            elseif dir == 2 then
                y = y + 1
                indir = 'S'
            else
                assert(dir == 3)
                y = y - 1
                indir = 'N'
            end
            result[#result].outdir = DIRECTION_REV[(DIRECTION[indir] + 2) % 4] -- 取下个路块 '入口' 的相反方向
            result[#result+1] = {coord = {x, y}, indir = indir}
        end
        result[#result].outdir = 'N'

        local road_track_slot_entities = {}
        for _, v in ipairs(result) do
            local game_object = get_road_game_object(v.coord)
            local slot_entities = get_road_track_slots(game_object, v.indir, v.outdir)
            for _, e in ipairs(slot_entities) do
                road_track_slot_entities[#road_track_slot_entities+1] = e
            end
        end

        --
        local raw_animation = animation.new_raw_animation()
        local skl = skeleton.build({{name = "root", s = {1.0, 1.0, 1.0}, r = {0.0, 0.0, 0.0, 1.0}, t = {0.0, 0.0, 0.0}}})

        local function calc_dist(p1, p2)
            local d = 0.0
            for i = 1, 3 do
                d = d + (p1[i] - p2[i]) ^ 2
            end
            return math.sqrt(d)
        end

        local it = {}
        local lt
        local total = 0.0
        local EPSILON <const> = 2 ^ -14
        for _, e in ipairs(road_track_slot_entities) do
            local wm = iom.worldmat(e)
            local s, r, t = math3d.srt(wm)

            local dist = 0.0
            if lt then
                dist = calc_dist(math3d.tovalue(lt), math3d.tovalue(t))

                -- 排除重复点
                if dist > EPSILON then
                    total = total + dist
                    it[#it+1] = {d = total, s = s, r = r, t = t}
                    lt = t
                end
            else
                it[#it+1] = {d = 0, s = s, r = r, t = t}
                lt = t
            end 
        end

        raw_animation:setup(skl, total)
        for _, v in ipairs(it) do
            raw_animation:push_prekey(
                "root",
                v.d,
                v.s, v.r, v.t
            )
        end

        local ani = raw_animation:build()
        local poseresult = animation.new_pose_result(#skl)
        poseresult:setup(skl)

        local ratio = 0
        local step = 1 / (#result - 1) / 30

        while ratio <= 1.0 do
            poseresult:do_sample(animation.new_sampling_context(1), ani, ratio, 0)
            poseresult:fetch_result()
            local mat = poseresult:joint(1)
            srts[#srts+1] = math3d.ref(mat)
            ratio = ratio + step
        end

        print("srts", #srts)
        remove_debug_prefab(2)
        -- add lorry
        local prefab_file_name = "/pkg/vaststars.resources/lorry.prefab"
        local prefab = ecs.create_instance(prefab_file_name)
        prefab.on_message = function()
        end
        iprefab_object.create(prefab, {
            data = {debug_component = 2},
        })
    end

    local span <const> = 1
    local iom_set_srt = iom.set_srt
    local math3d_srt = math3d.srt
    local bgfx = require "bgfx"

    test_funcs[2] = function ()
        -- update_fps()
        -- bgfx.dbg_text_print(8, 1, 0x03, ("DebugFPS: %.03f"):format(get_fps()))
        -- local bgfxstat = bgfx.get_stats("sdcpnmtv")
        -- bgfx.dbg_text_print(8, 2, 0x03, ("DrawCall: %-10d Triangle: %-10d Texture: %-10d cpu(ms): %04.4f gpu(ms): %04.4f fps: %d"):format(
        --     bgfxstat.numDraw, bgfxstat.numTriList, bgfxstat.numTextures, bgfxstat.cpu, bgfxstat.gpu, bgfxstat.fps
        -- ))
        -- bgfx.dbg_text_print(8, 3, 0x04, ("entities: %-10d"):format(get_entity_count()))

        local prefab = get_debug_prefab(2)
        if not prefab then
            return
        end

        local current = get_current()
        last_update_time = last_update_time or current       
        delta_time = (current - (last_update_time or current)) + (delta_time or 0)
        last_update_time = current

        -- while delta_time >= span do
        --     delta_time = delta_time - span
            idx = idx + 1
            if idx > #srts then
                return
            end
            iom_set_srt(prefab.root, math3d_srt(srts[idx]))
        -- end
    end
end

funcs[5] = function()
    local convert = {
        ["road"] = function(game_object)
            local e = w:singleton("road_types", "road_types:in")
            local road_types = e.road_types
            local x = game_object.x
            local y = game_object.y
            local rt = road_types[x][y]
            return {
                entity = "路1-" .. rt:sub(1,1) .. "型",
                x = x,
                y = y,
                dir = game_object.dir,
            }
        end,
        ["goods_station"] = function(game_object)
            return {
                entity = "车站",
                x = game_object.x,
                y = game_object.y,
                dir = "N",
            }
        end,
        ["logistics_center"] = function(game_object)
            return {
                entity = "物流中心",
                x = game_object.x,
                y = game_object.y,
                dir = "N",
            }
        end,
        ["container"] = function(game_object)
            return {
                entity = "箱子",
                x = game_object.x,
                y = game_object.y,
                dir = "N",
            }
        end,
        ["rock"] = function(game_object)
            return {
                entity = "货物",
                x = game_object.x,
                y = game_object.y,
                dir = "N",
            }
        end,
        ["pipe"] = function(game_object)
            local e = w:singleton("pipe_types", "pipe_types:in")
            local pipe_types = e.pipe_types
            local x = game_object.x
            local y = game_object.y
            local pt = pipe_types[x][y]
            return {
                entity = "管道1-" .. pt:sub(1,1) .. "型",
                x = x,
                y = y,
                dir = game_object.dir,
            }
        end,
    }

    local t = {}
    for game_object in w:select "building_type:in dir:in" do
        t[#t+1] = convert[game_object.building_type](game_object)
    end

    local fs        = require "filesystem"
    local lfs       = require "filesystem.local"
    local serialize = import_package "ant.serialize"

    local dumppath <const> = fs.path "/pkg/vaststars.gamerender/dump.lua"
    local lpath
    if not fs.exists(dumppath) then
        local p = dumppath:parent_path()
        lpath = p:localpath() / dumppath:filename():string()
    else
        lpath = dumppath:localpath()
    end
    local f <close> = lfs.open(lpath, "w")
    local c = serialize.stringify(t)
    f:write(c)

    print(c)
end

funcs[6] = function()
    print("world._frame", world._frame)
    world:print_cpu_stat()
end

funcs[7] = function()
    for e in w:select "shape_terrain:in" do
        w:remove(e)
    end
end

--------------
function debug_sys:ui_update()
    for _, i in debug_mb:unpack() do 
        local func = funcs[i]
        if func then
            func()
        end
    end
end

function debug_sys:start_frame()
    for _, func in ipairs(test_funcs) do
        func()
    end
end

function debug_sys:entity_init()
	for e in w:select "INIT" do
        add_entity_count()
    end
end

function debug_sys:entity_remove()
    for e in w:select "REMOVED" do
        dec_entity_count()
    end
end
