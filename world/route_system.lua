local ecs = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars|iui"

local ui_route_mb = world:sub {"ui", "route"}
local ui_route_new_close_mb = world:sub {"ui", "route_new", "close"}

local route_sys = ecs.system "route_system"

local route_ui_cmds = {}
route_ui_cmds["close"] = function ()
    iui.close("route")
    iui.open("construct", "construct.rml")
end

route_ui_cmds["add_route"] = function ()
    local station_list = {}

    for e in w:select "building:in" do
        if e.building.building_type == "logistics_center" then -- todo ?
            station_list[#station_list + 1] = {
                id = e.building.id,
                name = e.building.id .. "_test_name", -- todo
            }
        end
    end

    iui.open("route_new", "route_new.rml", station_list)
end

function route_sys:data_changed()
    local func
    for _, _, cmd in ui_route_mb:unpack() do
        func = route_ui_cmds[cmd]
        if func then
            func()
        end
    end

    for _ in ui_route_new_close_mb:unpack() do
        -- todo bad taste
        iui.close("route_new")
        iui.open("construct", "construct.rml")
    end
end
