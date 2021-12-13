local ecs = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars|iui"

local ui_route_mb = world:sub {"ui", "route"}
local ui_route_new_close_mb = world:sub {"ui", "route_new", "close"}

local route_sys = ecs.system "route_system"

local routes = {}
local route_ui_cmds = {}
route_ui_cmds["close"] = function ()
    iui.close("route")
    iui.open("construct", "construct.rml")
end

route_ui_cmds["show_route_new"] = function()
    local station_list = {}

    for e in w:select "building:in" do
        if e.building.building_type == "logistics_center" then -- todo ?
            station_list[#station_list + 1] = {
                id = e.building.id,
                name = "物流中心_" .. e.building.id, -- todo
            }
        end
    end

    iui.open("route_new", "route_new.rml", station_list)
end

route_ui_cmds["add_route"] = function(building_ids)
    local route_id = #routes+1
    routes[route_id] = building_ids

    iui.post("route", route_id)
end

route_ui_cmds["show_route"] = function(building_ids)
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

    for _ in ui_route_new_close_mb:unpack() do
        -- todo bad taste
        iui.close("route_new")
        iui.open("construct", "construct.rml")
    end
end
