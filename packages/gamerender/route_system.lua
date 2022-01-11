local ecs = ...
local world = ecs.world
local w = world.w

local ui_get_data = world:sub {"ui", "GET_DATA", "stations"}

local route_sys = ecs.system "route_system"
local routes = {}

local route_ui_cmds = {}
route_ui_cmds["show_route"] = function(route_id)
    local route = routes[route_id]
end

route_ui_cmds["new_route"] = function(building_ids)
    routes[#routes+1] = building_ids
end

function route_sys:data_changed()
    local func

    for _ in ui_get_data:each() do
        local logistics_centers = {}
        for e in w:select "route_endpoint:in name:in building:in" do
            e.building.id = math.random(1, 10000) -- todo
            logistics_centers[e.building.id] = {
                id = e.building.id,
                name = e.name,
            }
        end
        world:pub {"ui_message", "SET_DATA", {["stations"] = logistics_centers}}
    end
end
