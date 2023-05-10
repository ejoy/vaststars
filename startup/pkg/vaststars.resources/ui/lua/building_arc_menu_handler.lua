local spec = require "lua.building_arc_menu_spec"

local positions <const> = {
    [1] = {
        {top = "15.00vmin", left = "2vmin"},
    },
    [2] = {
        {top = "15.00vmin", left = "2vmin"},
        {top = "15.00vmin", left = "69.34vmin"},
    },
    [3] = {
        {top = "15.00vmin", left = "2vmin"},
        {top = "-2vmin", left = "35vmin"},
        {top = "15.00vmin", left = "69.34vmin"},
    },
    [4] = {
        {top = "15.00vmin", left = "2vmin"},
        {top = "0.00vmin", left = "21.62vmin"},
        {top = "0.00vmin", left = "48.48vmin"},
        {top = "15.00vmin", left = "69.34vmin"},
    },
    [5] = {
        {top = "15.00vmin", left = "2vmin"},
        {top = "3.00vmin", left = "16.62vmin"},
        {top = "-2vmin", left = "35vmin"},
        {top = "3.00vmin", left = "53.48vmin"},
        {top = "15.00vmin", left = "69.34vmin"},
    },
}

local DEFAULT <const> = {
    text = " ",
    message = " ",
    number = -1,
    show_number = false,
    show_icon_background = false,
    disabled = false,
    guide_progress = -1,
    animation = 'none',
}

return function(start)
    if spec[start.prototype_name] then
        local icon_pos = spec[start.prototype_name](start, DEFAULT)
        if #start.buttons > 0 then
            local pos = assert(icon_pos[#start.buttons], ("type(`%s`) button(%d)"):format(start.prototype_name, #start.buttons))
            for i = 1, #start.buttons do
                local v = start.buttons[i]
                v.left = pos[i].left
                v.top = pos[i].top
            end
        end
        start("buttons")
        return
    end

    start.buttons = {}
    if start.pickup_item then
        local v = setmetatable({}, {__index = DEFAULT})
        v.text = "收取物品"
        v.message = "pickup_item"
        v.background_image = "textures/cmdcenter/item-in.texture"
        start.buttons[#start.buttons + 1] = v
    end

    if start.show_set_recipe then
        local v = setmetatable({}, {__index = DEFAULT})
        v.text = "管理"
        v.message = "set_recipe"
        v.background_image = "textures/assemble/wheel.texture"
        start.buttons[#start.buttons + 1] = v
    end

    if start.show_set_item then
        local v = setmetatable({}, {__index = DEFAULT})
        v.text = "管理"
        v.message = "set_item"
        v.background_image = "textures/assemble/wheel.texture"
        start.buttons[#start.buttons + 1] = v
    end

    if start.place_item then
        local v = setmetatable({}, {__index = DEFAULT})
        v.text = "放置物品"
        v.message = "place_item"
        v.background_image = "textures/cmdcenter/item-out.texture"
        start.buttons[#start.buttons + 1] = v
    end

    if start.drone_depot_icon and start.drone_depot_icon ~= "" then
        local v = setmetatable({}, {__index = DEFAULT})
        v.background_image = start.drone_depot_icon
        v.number = start.drone_depot_count
        v.show_number = true
        v.show_icon_background = true
        start.buttons[#start.buttons + 1] = v
    end

    if start.station_item_icon and start.station_item_icon ~= "" then
        local v = setmetatable({}, {__index = DEFAULT})
        v.background_image = start.station_item_icon
        v.number = start.station_item_count
        v.show_number = true
        v.show_icon_background = true
        start.buttons[#start.buttons + 1] = v
    end

    if start.lorry_factory_dec_lorry then
        local v = setmetatable({}, {__index = DEFAULT})
        v.text = "车辆取消"
        v.message = "lorry_factory_stop_build"
        v.background_image = "textures/construct/truck-cancel.texture"
        start.buttons[#start.buttons + 1] = v
    end

    if start.lorry_factory_icon and start.lorry_factory_icon ~= "" then
        local v = setmetatable({}, {__index = DEFAULT})
        v.background_image = start.lorry_factory_icon
        v.number = start.lorry_factory_count
        v.show_number = true
        v.show_icon_background = true
        start.buttons[#start.buttons + 1] = v
    end

    if start.lorry_factory_inc_lorry then
        local v = setmetatable({}, {__index = DEFAULT})
        v.text = "增加车辆"
        v.message = "lorry_factory_inc_lorry"
        v.background_image = "textures/construct/truck-add.texture"
        start.buttons[#start.buttons + 1] = v
    end

    console.log("#start.buttons", #start.buttons)
    if #start.buttons > 0 then
        local pos = assert(positions[#start.buttons], #start.buttons)
        for i = 1, #start.buttons do
            local v = start.buttons[i]
            v.left = pos[i].left
            v.top = pos[i].top
        end
    end
    start("buttons")
end