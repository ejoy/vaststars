local ui_sys = require "ui_system"
local start = window.createModel "start" {
    show_select_route = false,
    stations = {},
    choice_field = "", -- begin or end
    choice_field_idxs = {},
    selected_item_idxs = {},
    error_tip = " ",

    -- todo
    station_name_1 = " ",
    station_name_2 = " ",
    station_id_1 = " ",
    station_id_2 = " ",
    selected_station_name_1 = "点击选择站点",
    selected_station_name_2 = "点击选择站点",
    flag = false,
}

local function __show_error_tip(err)
    local error_tip_element_id = "id-div-error-tip"
    start.error_tip = err
    element = document:getElementById(error_tip_element_id)
    if not element then
        console.log(("element_id(%s)|can not found"):format(error_tip_element_id))
        return
    end

    element.style.animation = ("%ds linear forwards error-tip-keyframes;"):format(1)
end

-- todo
local function __update_stations(stations)
    for idx, station in ipairs(stations) do
        start["station_id_" .. idx] = station.id
        start["station_name_" .. idx] = station.name
    end
end

function start.addRoute(event)
    ui_sys.post("@road", "new_route", start.choice_field_idxs)
end

function start.close(event)
    if not start.flag then -- todo
        return
    end

    ui_sys.post("route", "close")
end
window.setTimeout(function() start.flag = true end, 50)

function start.clickSelectRoute(event, choice_field)
    start.show_select_route = true
    start.choice_field = choice_field
end

function start.selectStation(event, item_idx)
    if not start.stations[item_idx] then
        __show_error_tip(("Can not found item_idx(%s)"):format(item_idx)) -- todo
        return
    end

    ui_sys.post("@route_new", "select_station", item_idx)
    start.show_select_route = false
    start.choice_field = ""
end

ui_sys.add_event_listener("route_new", {
    ["init"] = function(stations)
        start.stations = stations
        __update_stations(stations) -- todo
    end,
    ["select_station"] = function(idx)
        if start.selected_item_idxs[idx] then
            __show_error_tip(("already choice (%s)"):format(start.stations[idx].name))
            return
        end

        if start.choice_field == "begin" then
            start.selected_station_name_1 = start.stations[idx].name -- todo
            start.selected_item_idxs[idx] = true
            start.choice_field_idxs["begin"] = idx
        elseif start.choice_field == "end" then
            start.selected_station_name_2 = start.stations[idx].name -- todo
            start.selected_item_idxs[idx] = true
            start.choice_field_idxs["end"] = idx
        end
    end,
})
