local ecs = ...
local world = ecs.world
local w = world.w

local iprefab_proxy = ecs.import.interface "vaststars.utility|iprefab_proxy"
local m = ecs.system 'debug_system'
local debug_mb = world:sub {"debug"}

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
end
