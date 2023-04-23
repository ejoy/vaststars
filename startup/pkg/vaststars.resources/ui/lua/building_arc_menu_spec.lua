local t = {}

local ICON_POS <const> = {
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
        {top = "-2vmin", left = "35vmin"},
        {top = "3.00vmin", left = "53.48vmin"},
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

local ICON_POS1 <const> = {
    [1] = {
        {top = "15.00vmin", left = "69.34vmin"},
    },
}

t["建造中心"] = function (start, default)
    start.buttons = {}
    if start.show_set_recipe then
        local v = setmetatable({}, {__index = default})
        v.text = "管理"
        v.message = "set_recipe"
        v.background_image = "textures/assemble/wheel.texture"
        if start.guide_progress == 5 then
            v.animation = '0.4s linear 0s infinite alternate enlarge2'
        end
        start.buttons[#start.buttons + 1] = v
    end

    if start.construction_center_icon and start.construction_center_icon ~= "" then
        local v = setmetatable({}, {__index = default})
        v.background_image = start.construction_center_icon
        v.number = start.construction_center_multiple
        v.show_number = false
        v.show_icon_background = true
        start.buttons[#start.buttons + 1] = v
    end

    if start.item_transfer_place then
        local v = setmetatable({}, {__index = default})
        v.text = "传送启动"
        v.message = "item_transfer_place"
        v.background_image = "textures/construct/portal-out.texture"
        v.disabled = start.item_transfer_place_disabled
        v.disabled_background_image = "textures/construct/portal-out-disabled.texture"
        if start.guide_progress == 15 then
            v.animation = '0.4s linear 0s infinite alternate enlarge2'
        end
        start.buttons[#start.buttons + 1] = v
    end

    if start.construction_center_place then
        local v = setmetatable({}, {__index = default})
        v.text = "放置"
        v.message = "construction_center_place"
        v.background_image = "textures/factory/place-building.texture"
        v.number = start.construction_center_count
        v.show_number = start.construction_center_count > 0
        v.show_icon_background = false
        start.buttons[#start.buttons + 1] = v
    end

    return ICON_POS
end

t["建材箱"] = function (start, default)
    start.buttons = {}
    if start.construction_center_place then
        local v = setmetatable({}, {__index = default})
        v.text = "放置"
        v.message = "construction_center_place"
        v.background_image = "textures/factory/place-building.texture"
        v.number = start.construction_center_count
        v.show_number = start.construction_center_count > 0
        v.show_icon_background = false
        start.buttons[#start.buttons + 1] = v
    end

    return ICON_POS1
end

t["机身残骸"] = function (start, default)
    start.buttons = {}
    if start.item_transfer_subscribe then
        local v = setmetatable({}, {__index = DEFAULT})
        v.text = "传送设置"
        v.message = "item_transfer_subscribe"
        v.background_image = "textures/construct/portal-in.texture"
        if start.guide_progress == 10 then
            v.animation = '0.4s linear 0s infinite alternate enlarge2'
        end
        start.buttons[#start.buttons + 1] = v
    end

    return ICON_POS1
end

t["机翼残骸"] = function (start, default)
    start.buttons = {}
    if start.item_transfer_subscribe then
        local v = setmetatable({}, {__index = DEFAULT})
        v.text = "传送设置"
        v.message = "item_transfer_subscribe"
        v.background_image = "textures/construct/portal-in.texture"
        if start.guide_progress == 10 then
            v.animation = '0.4s linear 0s infinite alternate enlarge2'
        end
        start.buttons[#start.buttons + 1] = v
    end

    return ICON_POS1
end

t["机头残骸"] = function (start, default)
    start.buttons = {}
    if start.item_transfer_subscribe then
        local v = setmetatable({}, {__index = DEFAULT})
        v.text = "传送设置"
        v.message = "item_transfer_subscribe"
        v.background_image = "textures/construct/portal-in.texture"
        if start.guide_progress == 10 then
            v.animation = '0.4s linear 0s infinite alternate enlarge2'
        end
        start.buttons[#start.buttons + 1] = v
    end

    return ICON_POS1
end

t["机尾残骸"] = function (start, default)
    start.buttons = {}
    if start.item_transfer_subscribe then
        local v = setmetatable({}, {__index = DEFAULT})
        v.text = "传送设置"
        v.message = "item_transfer_subscribe"
        v.background_image = "textures/construct/portal-in.texture"
        if start.guide_progress == 10 then
            v.animation = '0.4s linear 0s infinite alternate enlarge2'
        end
        start.buttons[#start.buttons + 1] = v
    end

    return ICON_POS1
end

return t