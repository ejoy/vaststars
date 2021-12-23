local ecs = ...
local world = ecs.world
local w = world.w

local iprefab_proxy = ecs.import.interface "vaststars.utility|iprefab_proxy"
local m = ecs.system 'debug_system'
local debug_mb = world:sub {"debug"}
local animation_mb = world:sub {"animation"}
local slot_name <const> = "货物挂点"

function m:ui_update()
    for _, i in debug_mb:unpack() do
        for v in w:select "inserter:in prefab_proxy:in" do
            if i == 1 then
                iprefab_proxy.message(v, "play_animation_once", "DownToUp")
            elseif i == 2 then
                iprefab_proxy.message(v, "play_animation_once", "UpToDown")
            end
        end
    end

    for _, name, action, prefab_proxy in animation_mb:unpack() do
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
