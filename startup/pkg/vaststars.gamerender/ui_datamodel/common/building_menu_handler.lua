local ecs = ...
local world = ecs.world
local w = world.w

local ICONS <const> = ecs.require "vaststars.prototype|building_menu.icons"
local DESC <const> = ecs.require "vaststars.prototype|building_menu.desc"
local CUSTOM_COMMANDS <const> = ecs.require "vaststars.prototype|building_menu.custom_commands"
local AUDIOS <const> = ecs.require "vaststars.prototype|building_menu.audios"
local set_button_offset = ecs.require "ui_datamodel.common.sector_menu".set_button_offset

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
        desc = DESC[command] or "",
    }
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