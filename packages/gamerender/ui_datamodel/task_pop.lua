local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local global = require "global"
local M = {}

function M:create(object_id)
    local current_tech = global.science.current_tech
    return {
        items = {
            {icon = "textures/build_background/pic_assemble.texture"},
            {icon = "textures/build_background/pic_assemble.texture"},
            {icon = "textures/build_background/pic_assemble.texture"},
            {icon = "textures/build_background/pic_assemble.texture"}
        },
        task_name = current_tech and current_tech.name or "任务名称",
        task_desc = current_tech and current_tech.detail.desc or "任务描述",
        current_count = current_tech and current_tech.progress or 0,
        total_count = current_tech and current_tech.detail.count or 100
    }
end

function M:stage_ui_update(datamodel)
    
end

return M