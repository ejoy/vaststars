local BUTTON_POS = require "lua.button_pos"

local DEFAULT_OFFSETS = {
    [1] = {
        [1] = BUTTON_POS[3],
    },
    [2] = {
        [1] = BUTTON_POS[2],
        [2] = BUTTON_POS[4],
    },
    [3] = {
        [1] = BUTTON_POS[2],
        [2] = BUTTON_POS[3],
        [3] = BUTTON_POS[4],
    },
    [4] = {
        [1] = BUTTON_POS[2],
        [2] = BUTTON_POS[3],
        [3] = BUTTON_POS[4],
        [4] = BUTTON_POS[5],
    },
    [5] = {
        [1] = BUTTON_POS[1],
        [2] = BUTTON_POS[2],
        [3] = BUTTON_POS[3],
        [4] = BUTTON_POS[4],
        [5] = BUTTON_POS[5],
    }
}

local DEFAULT <const> = {
    params = "",
    icon = "",
    text = "",
    disabled = false,
}

local function show_buttons(start)
    -- console.log("#start.buttons", #start.buttons)
    if #start.buttons > 0 then
        local def = DEFAULT_OFFSETS[#start.buttons]
        assert(def, ("(%s) - (%s)"):format(start.prototype_name, #start.buttons))
        for i = 1, #start.buttons do
            for k, v in pairs(def[i]) do
                start.buttons[i][k] = v
            end
        end
    end
    start("buttons")
end

local function test(start, count)
    local buttons = {
        [1] = {
            icon = "/pkg/vaststars.resources/ui/textures/building-menu/pickup-item.texture",
            params = "-pickup-item",
        },
        [2] = {
            icon = "/pkg/vaststars.resources/ui/textures/building-menu/place-item.texture",
            params = "-place-item",
        },
        [3] = {
            icon = "/pkg/vaststars.resources/ui/textures/building-menu/teardown.texture",
            params = "-teardown",
        }, 
        [4] = {
            icon = "/pkg/vaststars.resources/ui/textures/building-menu/move.texture",
            params = "-move",
        },
        [5] = {
            icon = "/pkg/vaststars.resources/ui/textures/building-menu/clone.texture",
            params = "-clone",
        },
    }

    for i = 1, count do
        start.buttons[i] = buttons[i]
    end
    show_buttons(start)
end

return function(start)
    -- if test then
    --     return test(start, 5)
    -- end

    start.buttons = {}

    if start.show_remove_one then
        local v = setmetatable({}, {__index = DEFAULT})
        v.params = {"remove_one"}
        v.icon = "/pkg/vaststars.resources/ui/textures/building-menu-longpress/close.texture"
        start.buttons[#start.buttons + 1] = v
    end

    if start.show_start_teardown then
        local v = setmetatable({}, {__index = DEFAULT})
        v.params = {"start_teardown"}
        v.icon = "/pkg/vaststars.resources/ui/textures/building-menu-longpress/teardown.texture"
        start.buttons[#start.buttons + 1] = v
    end

    show_buttons(start)
end