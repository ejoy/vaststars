local ecs = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.ui|iui"
local iconstruct = ecs.import.interface "vaststars.gamerender|iconstruct"
local gameplay = import_package "vaststars.gameplay"

local ui_route_mb = world:sub {"ui", "route"}
local ui_route_new_close_mb = world:sub {"ui", "route_new", "close"}

local route_sys = ecs.system "route_system"
local iroute = ecs.interface "iroute"
local routes = {}

local function __get_all_building_infos()
    local building_infos = {}
    for e in w:select "building:in" do
        if e.building.building_type == "logistics_center" then -- todo ?
            building_infos[e.building.id] = {
                name = "物流中心_" .. e.building.id, -- todo
            }
        end
    end
    return building_infos
end

local function __get_all_route_infos()
    local building_infos = __get_all_building_infos()

    local route_infos = {}
    for _, route in pairs(routes) do
        route_infos[#route_infos + 1] = {text = building_infos[route["begin"]].name .. " -> " .. building_infos[route["end"]].name}
    end
    return route_infos
end

local route_ui_cmds = {}
route_ui_cmds["close"] = function ()
    iui.close("road")
    iui.open("construct", "construct.rml")
end

route_ui_cmds["show_route_new"] = function()
    iui.open("route_new", "route_new.rml", __get_all_building_infos(), __get_all_route_infos())
end

route_ui_cmds["show_route"] = function(route_id)
    local route = routes[route_id]
    local path = gameplay.path(route["begin"], route["end"])
    iconstruct.show_route(route["begin"], path)
end

route_ui_cmds["new_route"] = function(building_ids)
    local route_id = #routes+1
    routes[route_id] = building_ids
    iroute.show()
end

function route_sys:data_changed()
    local func
    for msg in ui_route_mb:each() do
        func = route_ui_cmds[msg[3]]
        if func then
            func(table.unpack(msg, 4))
        end
    end

    for _ in ui_route_new_close_mb:unpack() do
        -- todo bad taste
        iui.close("route_new")
        iui.open("construct", "construct.rml")
    end
end

function iroute.show()
    iui.open("road", "road.rml", __get_all_building_infos(), __get_all_route_infos())
end
