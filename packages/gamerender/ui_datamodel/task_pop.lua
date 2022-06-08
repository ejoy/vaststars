local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local global = require "global"
local close_taskui_event = mailbox:sub {"close_taskui"}
local M = {}

local function get_multiple(task)
    return string.unpack("<I2", task, 3)
end

function M:create(object_id)
    local current_tech = global.science.current_tech
    local tips = {}
    if current_tech and current_tech.detail.tips_pic then
        for _, value in ipairs(current_tech.detail.tips_pic) do
            tips[#tips+1] = {icon = value}
        end
    end
    local multiple = get_multiple(current_tech.detail.task)
    local total = current_tech and (current_tech.detail.count * 10^multiple) or 100
    return {
        items = tips,
        task_name = current_tech and current_tech.name or "任务名称",
        task_desc = current_tech and current_tech.detail.sign_desc[1].desc or "任务描述",
        current_count = current_tech and current_tech.progress or 0,
        total_count = total
    }
end

function M:stage_ui_update(datamodel)
    for _, _, _ in close_taskui_event:unpack() do
        gameplay_core.world_update = true
    end

end

return M