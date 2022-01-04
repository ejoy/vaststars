local ecs = ...
local world = ecs.world
local w = world.w

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
    local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
    local math3d = require "math3d"
    local prefab_file_name = "/pkg/vaststars.resources/road/C_road.prefab"
    local prefab = ecs.create_instance(prefab_file_name)
    prefab.on_message = function()
    end
    igame_object.new(prefab, {
        data = {debug_component = 1},
    })
end

-- test track
do
    local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
    local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
    local mathadapter = import_package "ant.math.adapter"

    local math3d        = require "math3d"
    local math3d_adapter= require "math3d.adapter"
    local animation = require "hierarchy".animation
    local skeleton = require "hierarchy".skeleton

    local new_vector_float3 = animation.new_vector_float3
    local new_vector_quaternion = animation.new_vector_quaternion

    local function build_track(translations, rotations, duration, ratio)
        local raw_animation = animation.new_raw_animation()
        raw_animation:push_key(translations, rotations, duration)
        local ani = raw_animation:build()

        local skl = skeleton.build({{name = "root", s = {1.0, 1.0, 1.0}, r = {0.0, 0.0, 0.0, 1.0}, t = {0.0, 0.0, 0.0}}})
        local poseresult = animation.new_pose_result(1)
        poseresult:setup(skl)
        poseresult:do_sample(animation.new_sampling_context(1), ani, ratio, 0)
        poseresult:fetch_result()

        local t = {}
        local len = poseresult:count()
        for i = 1, len do
            t[#t+1] = poseresult:joint(i)
        end
        return t
    end
    local translations
    local rotations
    local ratio = 1.1
    local times = 0

    funcs[4] = function ()
        translations = new_vector_float3()
        rotations = new_vector_quaternion()

        local prefab = get_debug_prefab(1)
        for _, e in ipairs(prefab.tag["*"]) do
            w:sync("slot?in name:in", e)
            if e.slot and e.name:match("^path.*$") then
                translations:insert(iom.get_position(e)) -- add translation key
                rotations:insert(iom.get_rotation(e))    -- add rotation key
            end
        end

        ratio = 0
        times = 0

        remove_debug_prefab(2)
        -- add lorry
        local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
        local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
        local math3d = require "math3d"
        local prefab_file_name = "/pkg/vaststars.resources/lorry.prefab"
        local prefab = ecs.create_instance(prefab_file_name)
        prefab.on_message = function()
        end
        igame_object.new(prefab, {
            data = {debug_component = 2},
        })
    end

    local ltask = require "ltask"
    local last_time = 0
    test_funcs[2] = function ()
        local prefab = get_debug_prefab(2)
        if not prefab then
            return
        end

        local _, now = ltask.now()
        if ratio <= 1 and now - last_time > 1 then
            local duration = 10.0
            local result = build_track(translations, rotations, duration, ratio) -- build track
            for k, v in ipairs(result) do
                iom.set_srt(prefab.root, math3d.srt(v))
            end

            times = times + 1
            ratio = ratio + 0.01
            last_time = now

            -- print(times)
        end
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

    for _, func in ipairs(test_funcs) do
        func()
    end
end
