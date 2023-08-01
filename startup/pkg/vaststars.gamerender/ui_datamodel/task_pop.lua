local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local gameplay_core = require "gameplay.core"
local global = require "global"
local close_taskui_event = mailbox:sub {"close_taskui"}
local iui = ecs.import.interface "vaststars.gamerender|iui"

local M = {}

local function get_multiple(task)
    return string.unpack("<I2", task, 3)
end

function M:create(object_id)
    local current_tech = global.science.current_tech
    local tips = {}
    if current_tech.detail.tips_pic then
        for _, value in ipairs(current_tech.detail.tips_pic) do
            tips[#tips+1] = {icon = value}
        end
    end
    local multiple = get_multiple(current_tech.detail.task)
    return {
        items = tips,
        task_name = current_tech.name,
        task_desc = current_tech.detail.sign_desc[1].desc,
        current_count = math.floor(current_tech.progress * 10^multiple),
        total_count = math.floor(current_tech.detail.count * 10^multiple),
    }
end

function M:stage_ui_update(datamodel)
    for _, _, _ in close_taskui_event:unpack() do
        gameplay_core.world_update = true
        iui.close("ui/task_pop.rml")
    end

end

return M