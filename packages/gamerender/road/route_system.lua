local ecs = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.ui|iui"
local iconstruct = ecs.import.interface "vaststars.gamerender|iconstruct"
local gameplay = import_package "vaststars.gameplay"

local ui_route_mb = world:sub {"ui", "route.rml"}
local ui_route_new_data_mb = world:sub {"ui", "route_new.rml", "__get_data"}
local ui_road_new_data_mb = world:sub {"ui", "road.rml", "__get_data"}

local route_sys = ecs.system "route_system"
local routes = {}

local route_ui_cmds = {}
route_ui_cmds["show_route"] = function(route_id)
    local route = routes[route_id]
    local path = gameplay.path(route[1], route[2])
    iconstruct.show_route(route[1], path)
end

route_ui_cmds["new_route"] = function(building_ids)
    routes[#routes+1] = building_ids
end

function route_sys:data_changed()
    local func
    for msg in ui_route_mb:each() do
        func = route_ui_cmds[msg[3]]
        if func then
            func(table.unpack(msg, 4))
        end
    end

    for _ in ui_route_new_data_mb:unpack() do
        local logistics_centers = {}
        for e in w:select "building:in" do
            if e.building.building_type == "logistics_center" then -- todo ?
                logistics_centers[e.building.id] = {
                    id = e.building.id,
                    name = "物流中心_" .. e.building.id,
                }
            end
        end
        iui.post("route_new.rml", "__set_data", logistics_centers)
    end

    for _ in ui_road_new_data_mb:unpack() do
        local logistics_centers = {}
        for e in w:select "building:in" do
            if e.building.building_type == "logistics_center" then -- todo ?
                logistics_centers[e.building.id] = {
                    id = e.building.id,
                    name = "物流中心_" .. e.building.id,
                }
            end
        end
        iui.post("road.rml", "__set_data", logistics_centers, routes)
    end
end
