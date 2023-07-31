local ui_sys = require "ui_system"
local start = ui_sys.createDataMode("start", {
    show_select_route = false,
    error_tip = " ",
    endpoint_names = {
        [1] = "点击选择站点",
        [2] = "点击选择站点",
    },
    route_endpoints = {},

    select_index = "", -- begin or end
    select_endpoint_ids = {},
})

local function show_error_tip(err)
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
    if #start.select_endpoint_ids ~= 2 then
        show_error_tip(("还未选择车站"))
        return
    end
    ui_sys.close()
end

function start.clickselectEndpoint(event, select_index)
    start.show_select_route = true
    start.select_index = select_index
end

function start.selectEndpoint(event, index)
    index = index + 1
    local endpoint = start.route_endpoints[index]
    if not endpoint then
        show_error_tip(("Can not found index(%s)"):format(index))
        return
    end

    for _, id in pairs(start.select_endpoint_ids) do
        if id == endpoint.id then
            show_error_tip(("already select id(%s)"):format(endpoint.id))
            return
        end
    end

    assert(start.select_index == 1 or start.select_index == 2)
    start.endpoint_names[start.select_index] = endpoint.name
    start("endpoint_names")

    start.select_endpoint_ids[start.select_index] = endpoint.id
    start.show_select_route = false
    start.select_index = 0
end
