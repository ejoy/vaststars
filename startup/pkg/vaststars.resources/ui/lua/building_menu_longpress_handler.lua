local TRANSFORM_DELTA <const> = 18
local LINE_MARGIN_RIGHT_DELTA <const> = -2
local LINE_TRANSFORM_DELTA <const> = -5
local BUILDING_MENU_POSITIONS = {}
for i = 1, 5 do
    BUILDING_MENU_POSITIONS[i] = {
        outer_transform = ("rotate(%sdeg)"):format(-TRANSFORM_DELTA * (i - 1)),
        inner_transform = ("rotate(%sdeg)"):format(TRANSFORM_DELTA * (i - 1)),
        line_margin_right = ("%svmin"):format(LINE_MARGIN_RIGHT_DELTA * (i - 1)),
        line_transform = ("rotate(%sdeg)"):format(LINE_TRANSFORM_DELTA * (i - 1))
    }
end

local DEFAULT_OFFSETS = {
    [1] = {
        [1] = BUILDING_MENU_POSITIONS[3],
    },
    [2] = {
        [1] = BUILDING_MENU_POSITIONS[2],
        [2] = BUILDING_MENU_POSITIONS[4],
    },
    [3] = {
        [1] = BUILDING_MENU_POSITIONS[2],
        [2] = BUILDING_MENU_POSITIONS[3],
        [3] = BUILDING_MENU_POSITIONS[4],
    },
    [4] = {
        [1] = BUILDING_MENU_POSITIONS[2],
        [2] = BUILDING_MENU_POSITIONS[3],
        [3] = BUILDING_MENU_POSITIONS[4],
        [4] = BUILDING_MENU_POSITIONS[5],
    },
    [5] = {
        [1] = BUILDING_MENU_POSITIONS[1],
        [2] = BUILDING_MENU_POSITIONS[2],
        [3] = BUILDING_MENU_POSITIONS[3],
        [4] = BUILDING_MENU_POSITIONS[4],
        [5] = BUILDING_MENU_POSITIONS[5],
    }
}

local DEFAULT <const> = {
    command = "",
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

return function(start)
    start.buttons = {}
    if start.teardown then
        local v = setmetatable({}, {__index = DEFAULT})
        v.command = "teardown"
        v.background_image = "/pkg/vaststars.resources/ui/textures/building-menu-longpress/teardown.texture"
        start.buttons[#start.buttons + 1] = v
    end

    show_buttons(start)
end