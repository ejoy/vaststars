local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local bgfx          = require "bgfx"
local math3d        = require "math3d"
local iUiRt         = ecs.import.interface "ant.rmlui|iuirt"
local ientity       = ecs.import.interface "ant.render|ientity"
local imaterial     = ecs.import.interface "ant.asset|imaterial"
local ivs		    = ecs.import.interface "ant.scene|ivisible_state"
local global = require "global"
local statistics_mb = mailbox:sub {"statistics"}

local M = {}

local queuename = "statistic_chart_queue"
local canvas_size_w = 0
local canvas_size_h = 0
local chart_type = 0
local chart_eid = {}
local chart_data = {}
local filter_type = "5s"
local chart_color_table = {}
local function hide_chart()
    for _, eid in ipairs(chart_eid) do
        local e <close> = w:entity(eid)
        ivs.set_state(e, "statistic_chart", false)
    end
end

function M:create(object_id)
    if #chart_color_table < 1 then
        local a = 1.0
        for i = 1, 10 do
            chart_color_table[#chart_color_table + 1] = {1, 0.5, 1.0 - i * 0.1, a}
        end
        for i = 1, 10 do
            chart_color_table[#chart_color_table + 1] = {1, 1.0 - i * 0.1, 0, a}
        end
    end
    chart_data = {}
    filter_type = "5s"
    chart_type = 0
    hide_chart()
    return {
        items = {},
        total = 0
    }
end
local interval = 1

local function update_vb(eid, points)
    local vb = {}
    for _, pt in ipairs(points) do
        vb[#vb + 1] = pt[1]
        vb[#vb + 1] = pt[2]
        vb[#vb + 1] = pt[3]
    end
    local e <close> = w:entity(eid, "simplemesh:in")
    local mesh = e.simplemesh
    bgfx.update(mesh.vb.handle, 0, bgfx.memory_buffer("fff", vb));
end

local tick_count = 0
local step = 0
local line_count = 50
local start_x = 0


local function update_chart(group, total)
    local line_list = chart_data[group.cfg.name]
    if not chart_data[group.cfg.name] then
        local lines = {{start_x, 0, 0.5}, {start_x + step, 0, 0.5}}
        for i = 2, line_count do
            local tail = lines[#lines]
            lines[#lines + 1] = {tail[1], tail[2], tail[3]}
            lines[#lines + 1] = {start_x + i * step, 0, 0.5}
        end
        chart_data[group.cfg.name] = lines
        line_list = lines
    end
    local line_idx = 1
    local framecount = #group.frames
    local index = group.tail
    
    local totalframe = total.frames
    for count = 1, framecount do
        local frame = group.frames[index]
        line_list[line_idx][2] = (frame.power / totalframe[index].power) * canvas_size_h
        if count > 1 and count < framecount then
            line_list[line_idx + 1][2] = line_list[line_idx][2]
            line_idx = line_idx + 1
        end
        line_idx = line_idx + 1
        index = index + 1
        if index > framecount then
            index = 1
        end
    end
    local colorcount = #chart_color_table
    local colorindex = math.floor((group.power / total.power) * colorcount)
    if colorindex < 1 then
        colorindex = 1
    elseif colorindex > colorcount then
        colorindex = colorcount
    end
    local color = chart_color_table[colorindex]
    if group.eid then
        local e <close> = w:entity(group.eid)
        ivs.set_state(e, "statistic_chart", true)
        imaterial.set_property(e, "u_color", math3d.vector(color))
        update_vb(group.eid, line_list)
    else
        group.eid = ientity.create_screen_line_list("", line_list, nil, {u_color = color, u_canvas_size = {canvas_size_w, canvas_size_h, 0, 0} }, true, "translucent", queuename)
        chart_eid[#chart_eid + 1] = group.eid
    end
    return color
end

function M:stage_ui_update(datamodel)
    local gid = iUiRt.get_group_id("statistic_chart")
    if gid and canvas_size_w == 0 then
        local g = ecs.group(gid)
        g:enable "view_visible"
        g:enable "scene_update"
        local qe = w:first(queuename .." render_target:in")
        local rt = qe.render_target
        local vr = rt.view_rect
        canvas_size_w, canvas_size_h = vr.w, vr.h
        step = canvas_size_w / line_count
    end

    for _, _, _, type, value in statistics_mb:unpack() do
        if type == "filter_type" and filter_type ~= value then
            filter_type = value
            hide_chart()
        elseif type == "chart_type" then
            local nv = math.floor(value)
            if chart_type ~= nv then
                chart_type = nv
                hide_chart()
            end
        end
    end

    interval = interval + 1
    if interval > 5 then
        interval = 1
        local power_group = global.statistic.power_group
        local items = {}
        if chart_type == 0 then
            local total = global.statistic.power_consumed[filter_type]
            datamodel.total = total.power
            for _, group in pairs(power_group) do
                local node = group[filter_type]
                if node.consumer then
                    local fc = update_chart(node, total)
                    local ic = {math.floor(fc[1] * 255), math.floor(fc[2] * 255), math.floor(fc[3] * 255)}
                    items[#items + 1] = {icon = node.cfg.icon, count = group.count, power = node.power, color = ic}
                end
            end
        elseif chart_type == 1 then
            local total = global.statistic.power_generated[filter_type]
            datamodel.total = total.power
            for _, group in pairs(power_group) do
                local node = group[filter_type]
                if not node.consumer then
                    local fc = update_chart(node, total)
                    local ic = {math.floor(fc[1] * 255), math.floor(fc[2] * 255), math.floor(fc[3] * 255)}
                    items[#items + 1] = {icon = node.cfg.icon, count = group.count, power = node.power, color = ic}
                end
            end
        elseif chart_type == 2 then
        end
        table.sort(items, function (a, b) return a.power > b.power end)
        datamodel.items = items
        self:flush()
    end
end
return M