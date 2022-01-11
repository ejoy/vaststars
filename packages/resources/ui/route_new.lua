local ui_sys = require "ui_system"
local start = window.createModel "start" {
    show_select_route = false,
    stations = {},
    choice_field = "", -- begin or end
    route_building_ids = {},
    selected_building_ids = {},
    error_tip = " ",

    starting_station_name = "点击选择站点",
    ending_station_name = "点击选择站点",
}

local function __show_error_tip(err)
    local error_tip_element_id = "id-div-error-tip"
    start.error_tip = err
    local element = document:getElementById(error_tip_element_id)
    if not element then
        console.log(("element_id(%s)|can not found"):format(error_tip_element_id))
        return
    end

    element.style.animation = ("%ds linear forwards error-tip-keyframes;"):format(1)
end

function start.addRoute(event)
    if #start.route_building_ids ~= 2 then
        __show_error_tip(("还未选择车站"))
        return
    end
    ui_sys.pub("ui", "route_new", "new_route", start.route_building_ids)
    ui_sys.close("route_new.rml")
end

function start.close(event)
    ui_sys.close("route_new.rml")
end

function start.clickSelectStation(event, choice_field)
    start.show_select_route = true
    start.choice_field = choice_field
end

function start.selectStation(event, building_id)
    if not start.stations[building_id] then
        __show_error_tip(("Can not found building_id(%s)"):format(building_id))
        return
    end

    if start.selected_building_ids[building_id] then
        __show_error_tip(("already choice (%s)"):format(start.stations[building_id].name))
        return
    end

    if start.choice_field == "begin" then
        start.starting_station_name = start.stations[building_id].name
        start.selected_building_ids[building_id] = true
        start.route_building_ids[1] = building_id
    elseif start.choice_field == "end" then
        start.ending_station_name = start.stations[building_id].name
        start.selected_building_ids[building_id] = true
        start.route_building_ids[2] = building_id
    end

    start.show_select_route = false
    start.choice_field = ""
end

window.onload = function()
    ui_sys.pub("ui", "GET_DATA", "stations")
end

ui_sys.addEventListener({
    ["SET_DATA"] = function(data)
        for k, v in pairs(data) do
            if k == "stations" then
                local t = {}
                for k1, v1 in pairs(v) do
                    t[#t+1] = v1
                end
                start.stations = t
            end
        end
    end,
})
