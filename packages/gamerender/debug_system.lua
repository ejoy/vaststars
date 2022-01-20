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

--
local get_track_joint; do
    local hierarchy = require "hierarchy"
    local animation = hierarchy.animation
    local skeleton = hierarchy.skeleton

    function get_track_joint(translations, rotations, duration, ratio)
        local raw_animation = animation.new_raw_animation()
        local skl = skeleton.build({{name = "root", s = {1.0, 1.0, 1.0}, r = {0.0, 0.0, 0.0, 1.0}, t = {0.0, 0.0, 0.0}}})

        raw_animation:push_key(skl, {translations}, {rotations}, duration)
        local poseresult = animation.new_pose_result(#skl)
        poseresult:setup(skl)
        poseresult:do_sample(animation.new_sampling_context(), raw_animation:build(), ratio)
        poseresult:fetch_result()
        if poseresult:count() < 1 then
            return
        end

        return poseresult:joint(1)
    end
end



local m = ecs.system 'debug_system'
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
    for _, name, action, game_object in animation_mb:unpack() do
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
            "vaststars.gamerender|building",
        },
        data = {
            name = "",
            building = {
                building_type = "logistics_center",
                area = {3, 3},
            },
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
        w:sync("building:in x:in y:in", game_object)
        local function packCoord(x, y)
            print(x, y)
            return x | (y<<8)
        end

        local gameplay_adapter = w:singleton("gameplay_world", "gameplay_world:in")
        if gameplay_adapter then
            w:sync("scene:in", prefab.root)
            gameplay_adapter.gameplay_world:create_entity {
                station = {
                    id = prefab.root.scene.id,
                    position = packCoord(game_object.x, game_object.y + (-1 * (game_object.building.area[2] // 2)) - 1),
                }
            }
        end
    end
    template.data.building.tile_coord = {0x7b,0x83}
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
            "vaststars.gamerender|building",
        },
        data = {
            name = "",
            building = {
                building_type = "logistics_center",
                area = {3, 3},
            },
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
        w:sync("building:in x:in y:in", game_object)
        local function packCoord(x, y)
            print(x, y)
            return x | (y<<8)
        end

        local gameplay_adapter = w:singleton("gameplay_world", "gameplay_world:in")
        if gameplay_adapter then
            w:sync("scene:in", prefab.root)
            gameplay_adapter.gameplay_world:create_entity {
                station = {
                    id = prefab.root.scene.id,
                    position = packCoord(game_object.x, game_object.y + (-1 * (game_object.building.area[2] // 2)) - 1),
                }
            }
        end
    end
    template.data.building.tile_coord = {0x83,0x84}
    iprefab_object.create(new_prefab, template)

    --
end

-- test track
do
    local function get_endpoint_coord(id)
        for game_object in w:select "route_endpoint:in x:in y:in" do
            local prefab_object = igame_object.get_prefab_object(game_object)
            w:sync("scene:in ", prefab_object.root)
            w:sync("building:in", game_object)
            if prefab_object.root.scene.id == id then
                return {game_object.x, game_object.y + (-1 * (game_object.building.area[2] // 2)) - 1}
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

    local function get_road_path(road_game_object, indir, outdir)
        local e = w:singleton("road_types", "road_types:in")
        w:sync("x:in y:in", road_game_object)
        local road_type_dir = (e.road_types[road_game_object.x][road_game_object.y])
        local rt = road_type_dir:sub(1, 1)
        local dir = road_type_dir:sub(2, 2)

        indir = (DIRECTION[indir] - DIRECTION[dir]) % 4
        outdir = (DIRECTION[outdir] - DIRECTION[dir]) % 4
        local t = config.road_track[rt][DIRECTION_REV[indir]][DIRECTION_REV[outdir]]

        local r = {}
        for _, v in ipairs(t) do
            r[#r+1] = road_game_object.prefab_slot_cache[v]
        end
        return r, rt
    end

    local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
    local iprefab_object = ecs.import.interface "vaststars.gamerender|iprefab_object"
    local math3d        = require "math3d"
    local animation = require "hierarchy".animation
    local new_vector_float3 = animation.new_vector_float3
    local new_vector_quaternion = animation.new_vector_quaternion

    local srts = {}
    local idx = 1
    local run = true
    local last_update_time
    local delta_time

    funcs[4] = function ()
        if next(srts) then
            idx = 1
            last_update_time = nil
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

        assert(#endpoint_ids == 2)
        local gameplay_adapter = w:singleton("gameplay_world", "gameplay_world:in")

        local road_path
        if run then
            road_path = gameplay_adapter.gameplay_world:road_path(endpoint_ids[1], endpoint_ids[2])
        else
            road_path = gameplay_adapter.gameplay_world:road_path(endpoint_ids[2], endpoint_ids[1])
        end

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

        --
        local translations = new_vector_float3()
        local rotations = new_vector_quaternion()
        for i1, v in ipairs(result) do
            local game_object = get_road_game_object(v.coord)
            local rpath, rt = get_road_path(game_object, v.indir, v.outdir)
            for i2, e in ipairs(rpath) do
                if i1 ~= #result and i2 == #rpath then
                    break
                end

                local wm = iom.worldmat(e)
		        local s, r, t = math3d.srt(wm)
                translations:insert(t) -- add translation key
                rotations:insert(r)    -- add rotation key

                print("key frame: ", rt, ",", table.concat(math3d.tovalue(t), ", "))
            end
        end

        srts = {}
        idx = 1
        last_update_time = nil

        local base = 100
        local duration = (translations:size() - 1) * base * 20
        local ratio = 0
        local step = 1/((translations:size() - 1) * base)

        while ratio <= 1 do
            local mat = get_track_joint(translations, rotations, duration, ratio)
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

    local span <const> = 8
    local iom_set_srt = iom.set_srt
    local math3d_srt = math3d.srt
    local bgfx = require "bgfx"

    test_funcs[2] = function ()
        update_fps()
        bgfx.dbg_text_print(8, 1, 0x03, ("DEBUGFPS: %.03f"):format(get_fps()))
        local bgfxstat = bgfx.get_stats("sdcpnmtv")
        bgfx.dbg_text_print(8, 2, 0x03, ("DrawCall: %-10d Triangle: %-10d Texture: %-10d cpu(ms): %04.4f gpu(ms): %04.4f fps: %d"):format(
            bgfxstat.numDraw, bgfxstat.numTriList, bgfxstat.numTextures, bgfxstat.cpu, bgfxstat.gpu, bgfxstat.fps
        ))

        local prefab = get_debug_prefab(2)
        if not prefab then
            return
        end

        local current = get_current()
        last_update_time = last_update_time or current       
        delta_time = (current - (last_update_time or current)) + (delta_time or 0)
        last_update_time = current

        while delta_time >= span do
            delta_time = delta_time - span
            idx = idx + 1
            if idx > #srts then
                return
            end
            iom_set_srt(prefab.root, math3d_srt(srts[idx]))
            -- print("run", get_current())
        end
    end
end

funcs[5] = function()
    local convert = {
        ["road"] = function(game_object)
            local e = w:singleton("road_types", "road_types:in")
            local road_types = e.road_types
            local x = game_object.building.tile_coord[1]
            local y = game_object.building.tile_coord[2]
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
                x = game_object.building.tile_coord[1],
                y = game_object.building.tile_coord[2],
                dir = "N",
            }
        end,
        ["logistics_center"] = function(game_object)
            return {
                entity = "物流中心",
                x = game_object.building.tile_coord[1],
                y = game_object.building.tile_coord[2],
                dir = "N",
            }
        end,
        ["container"] = function(game_object)
            return {
                entity = "箱子",
                x = game_object.building.tile_coord[1],
                y = game_object.building.tile_coord[2],
                dir = "N",
            }
        end,
        ["rock"] = function(game_object)
            return {
                entity = "货物",
                x = game_object.building.tile_coord[1],
                y = game_object.building.tile_coord[2],
                dir = "N",
            }
        end,
        ["pipe"] = function(game_object)
            local e = w:singleton("pipe_types", "pipe_types:in")
            local pipe_types = e.pipe_types
            local x = game_object.building.tile_coord[1]
            local y = game_object.building.tile_coord[2]
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
    for game_object in w:select "building:in dir:in" do
        t[#t+1] = convert[game_object.building.building_type](game_object)
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
    world:print_cpu_stat()
    for k, v in pairs(world:memory()) do
        print(k, v)
    end

    for game_object in w:select "game_object:in" do
        local prefab_object = igame_object.get_prefab_object(game_object)
        prefab_object:remove()
    end
end

--------------
function m:ui_update()
    for _, i in debug_mb:unpack() do 
        local func = funcs[i]
        if func then
            func()
        end
    end


end

function m:start_frame()
    for _, func in ipairs(test_funcs) do
        func()
    end
end
