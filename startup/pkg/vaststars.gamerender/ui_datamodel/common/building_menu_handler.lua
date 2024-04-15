local ecs = ...
local world = ecs.world
local w = world.w

local ICONS <const> = ecs.require "vaststars.prototype|menu.icons"
local DESC <const> = ecs.require "vaststars.prototype|menu.desc"
local BUILDING_CUSTOM_MENU <const> = ecs.require "vaststars.prototype|menu.building_custom_menu"
local set_button_offset = ecs.require "ui_datamodel.common.sector_menu".set_button_offset

local function create_button(command)
    local k = "building_menu." .. command
    return {
        command = command,
        background_image = ICONS[k],
        number = "", -- can have a value of either a digit or '+', '' 
        selected = false,
        desc = DESC[k] or "",
    }
end

return function(prototype_name, status)
    if not BUILDING_CUSTOM_MENU[prototype_name] then
        log.error("No custom commands for building: " .. prototype_name)
        return {}
    end

    local buttons = {}
    for _, command in ipairs(BUILDING_CUSTOM_MENU[prototype_name] or {}) do
        if status[command] then
            local button = create_button(command)
            buttons[#buttons + 1] = button
        end
    end
    set_button_offset(buttons)

    return buttons
end