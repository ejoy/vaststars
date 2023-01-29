local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local chart_id_mb = mailbox:sub {"chart_id"}
local global = require "global"
local M = {}

function M:create(object_id)
    return {
        items = {},
        total = 0
    }

end
local interval = 1
local chart_id = 0
function M:stage_ui_update(datamodel)
    for _, _, _, id in chart_id_mb:unpack() do
        chart_id = id
    end
    interval = interval + 1
    if interval > 10 then
        interval = 1
        local power_group = global.statistic.power_group
        local items = {}
        if chart_id == 0 then
            for _, group in pairs(power_group) do
                if group.consumer then
                    items[#items + 1] = {icon = group.cfg.icon, count = group.count, power = group.power}
                end
            end
        elseif chart_id == 1 then
            for _, group in pairs(power_group) do
                if not group.consumer then
                    items[#items + 1] = {icon = group.cfg.icon, count = group.count, power = group.power}
                end
            end
        elseif chart_id == 2 then
        end
        table.sort(items, function (a, b) return a.power > b.power end)
        datamodel.items = items
        if chart_id == 0 then
            datamodel.total = global.statistic.power_consumed
        elseif chart_id == 1 then
            datamodel.total = global.statistic.power_generated
        elseif chart_id == 2 then
        end
        self:flush()
    end
end
return M