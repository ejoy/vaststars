local ecs = ...
local world = ecs.world
local w = world.w

local m = ecs.system 'debug_system'
local debug_mb = world:sub {"debug"}
local funcs = {}
local test_funcs = {}
------
-- test animation
funcs[1] = function ()
    local iprefab_proxy = ecs.import.interface "vaststars.utility|iprefab_proxy"
    for v in w:select "inserter:in prefab_proxy:in" do
        iprefab_proxy.message(v, "play_animation_once", "DownToUp")
    end
end

funcs[2] = function ()
    local iprefab_proxy = ecs.import.interface "vaststars.utility|iprefab_proxy"
    for v in w:select "inserter:in prefab_proxy:in" do
        iprefab_proxy.message(v, "play_animation_once", "UpToDown")
    end
end

test_funcs[1] = function ()
    local animation_mb = world:sub {"animation"}
    for _, name, action, prefab_proxy in animation_mb:unpack() do
        local slot_name <const> = "货物挂点"
        local iprefab_proxy = ecs.import.interface "vaststars.utility|iprefab_proxy"
        if action == "play" then
            local prefab = ecs.create_instance("/pkg/vaststars.resources/rock.prefab")
            prefab.on_message = function(prefab, cmd)
                if cmd == "remove" then
                    prefab:remove()
                end
            end
            iprefab_proxy.slot_attach(prefab_proxy, slot_name, world:create_object(prefab))
        elseif action == "stop" then
            iprefab_proxy.slot_detach(prefab_proxy, slot_name)
        end
    end
end

------
funcs[3] = function ()
    local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
    local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
    local math3d = require "math3d"
    local prefab_file_name = "/pkg/vaststars.resources/road/C_road.prefab"
    local prefab = ecs.create_instance(prefab_file_name)
    prefab.on_message = function()
    end
    local srt = {}
    srt.s = math3d.vector(0.10, 0.10, 0.10)
    iom.set_srt(prefab.root, srt.s, srt.r, srt.t)
    igame_object.new(prefab, {
        data = {debug_component = true},
    })
end

funcs[4] = function ()
    local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
    for game_object in w:select "debug_component:in" do
        local slots = {}
        local prefab = igame_object.get_prefab(game_object)
        for _, e in ipairs(prefab.tag["*"]) do
            w:sync("slot?in name:in", e)
            if e.slot then
                slots[e.name] = e
            end
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
