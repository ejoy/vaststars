local ecs, mailbox = ...
local world = ecs.world

local inventory_mb = mailbox:sub {"inventory"}
local research_tasks_mb = mailbox:sub {"research_tasks"}
local statistical_data_mb = mailbox:sub {"statistical_data"}
local game_settings_mb = mailbox:sub {"game_settings"}
local quit_mb = mailbox:sub {"quit"}

local global = require "global"
local objects = require "objects"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iprototype = require "gameplay.interface.prototype"
local audio = import_package "ant.audio"
local gameplay_core = require "gameplay.core"

local M = {}

local function __get_new_tech_count(tech_list)
    local count = 0
    for _, tech in ipairs(tech_list) do
        if global.science.tech_picked_flag[tech.detail.name] then
            count = count + 1
        end
    end
    return count
end

function M:create()
    return {
        tech_count = __get_new_tech_count(global.science.tech_list),
    }
end

function M:stage_ui_update(datamodel)
    for _ in inventory_mb:unpack() do
        audio.play("event:/ui/button1")
        for _, object in objects:all() do -- TODO: optimize
            local typeobject = iprototype.queryByName(object.prototype_name)
            if iprototype.has_type(typeobject.type, "base") then
                iui.open({"inventory.rml"}, object.id)
                break
            end
        end
    end

    for _ in research_tasks_mb:unpack() do
        audio.play("event:/ui/button1")
        iui.open({"science.rml"})
    end

    for _ in statistical_data_mb:unpack() do
        audio.play("event:/ui/button1")
        iui.open({"statistics.rml"})
    end

    for _ in game_settings_mb:unpack() do
        audio.play("event:/ui/button1")
        iui.open({"option_pop.rml"})
    end

    for _ in quit_mb:unpack() do
        audio.play("event:/ui/button1")
        gameplay_core.world_update = true
        world:pub {"rmlui_message_close", "main_menu.rml"}
    end
end

function M:update_tech(datamodel)
    datamodel.tech_count = __get_new_tech_count(global.science.tech_list)
end

return M