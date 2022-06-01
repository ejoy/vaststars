local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local global = require "global"
local M = {}

function M:create(object_id)
    local current_tech = global.science.current_tech
    local tips = {}
    if current_tech then
        for _, value in ipairs(current_tech.detail.tips_pic) do
            tips[#tips+1] = {icon = value}
        end
    end
    return {
        items = tips,
        task_name = current_tech and current_tech.name or "任务名称",
        task_desc = current_tech and current_tech.detail.desc or "任务描述",
        current_count = current_tech and current_tech.progress or 0,
        total_count = current_tech and current_tech.detail.count or 100
    }
end

function M:stage_ui_update(datamodel)
    
end

return M