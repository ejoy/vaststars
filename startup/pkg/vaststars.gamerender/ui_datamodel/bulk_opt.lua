local ecs, mailbox = ...
local world = ecs.world

local BUTTONS = {
    { command = "remove", icon = "/pkg/vaststars.resources/ui/textures/bulk-opt/remove.texture", },
    { command = "move",   icon = "/pkg/vaststars.resources/ui/textures/bulk-opt/move.texture", },
}
local CONSTANT <const> = require "gameplay.interface.constant"
local CHANGED_FLAG_BUILDING <const> = CONSTANT.CHANGED_FLAG_BUILDING
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

local set_button_offset = ecs.require "ui_datamodel.common.sector_menu".set_button_offset
local remove_mb = mailbox:sub {"remove"}
local global = require "global"
local teardown = ecs.require "editor.teardown"
local gameplay_core = require "gameplay.core"
local iinventory = require "gameplay.interface.inventory"
local show_message = ecs.require "show_message".show_message
local iui = ecs.require "engine.system.ui_system"
local update_buildings_state = ecs.require "ui_datamodel.common.bulk_opt".update_buildings_state
local iroadnet = ecs.require "engine.roadnet"

local M = {}
function M.create()
    local buttons = {}
    for _, v in ipairs(BUTTONS) do
        buttons[#buttons+1] = {
            command = v.command,
            background_image = v.icon,
        }
    end
    set_button_offset(buttons)

    return {
        buttons = buttons,
    }
end

function M.update(datamodel)
    for _ in remove_mb:unpack() do
        local full = false
        for gameplay_eid in pairs(global.selected_buildings) do
            teardown(gameplay_eid)
            local e = assert(gameplay_core.get_entity(gameplay_eid))
            if not iinventory.place(gameplay_core.get_world(), e.building.prototype, 1) then
                full = true
            end
        end

        gameplay_core.set_changed(CHANGED_FLAG_BUILDING)

        -- the building directly go into the backpack
        if full then
            show_message("backpack is full")
        end

        global.selected_buildings = {}
    end
end

function M.gesture_tap()
    update_buildings_state(global.selected_buildings, "opaque", "null", RENDER_LAYER.BUILDING)
    iroadnet:flush()

    iui.redirect("/pkg/vaststars.resources/ui/construct.html", "bulk_opt_exit")
end

return M