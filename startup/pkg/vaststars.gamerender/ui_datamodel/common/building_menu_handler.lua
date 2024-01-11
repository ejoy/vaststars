local ecs = ...
local world = ecs.world
local w = world.w

local ICONS <const> = ecs.require "vaststars.prototype|building_menu.icons"
local CUSTOM_COMMANDS <const> = ecs.require "vaststars.prototype|building_menu.custom_commands"
local AUDIOS <const> = ecs.require "vaststars.prototype|building_menu.audios"

local TRANSFORM_DELTA <const> = 16.5
local BUILDING_MENU_POSITIONS = {}
for i = 1, 5 do
    BUILDING_MENU_POSITIONS[i] = {
        outer_transform = ("rotate(%sdeg)"):format(-TRANSFORM_DELTA * (i - 1)),
        inner_transform = ("rotate(%sdeg)"):format(TRANSFORM_DELTA * (i - 1)),
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

local COMMAND_HANDLERS <const> = {
    ["transfer"] = function(status, button)
        button.number = status.transfer_count
        return button
    end,
}

local function create_button(command)
    return {
        command = command,
        background_image = ICONS[command],
        number = "", -- can have a value of either a digit or '+', '' 
        selected = false,
        audio = AUDIOS[command],
    }
end

local function set_button_offset(buttons)
    -- print("#buttons", #buttons)
    if #buttons > 0 then
        local offsets = DEFAULT_OFFSETS[#buttons] or error(("(%s)"):format(#buttons))
        for i = 1, #buttons do
            for k, v in pairs(offsets[i]) do
                buttons[i][k] = v
            end
        end
    end
end

return function(prototype_name, status)
    if not CUSTOM_COMMANDS[prototype_name] then
        log.error("No custom commands for building: " .. prototype_name)
        return {}
    end

    local buttons = {}
    for _, command in ipairs(CUSTOM_COMMANDS[prototype_name] or {}) do
        if status[command] then
            local button = create_button(command)
            local h = COMMAND_HANDLERS[command]
            if h then
                button = h(status, button)
            end
            buttons[#buttons + 1] = button
        end
    end
    set_button_offset(buttons)

    return buttons
end