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
        ivs.set_state(e, queuename, false)
    end
end
local grid = {}
local function create_grid(row, col)
    local lines = {}
    local rowstep = canvas_size_h / row
    for index = 1, row - 1 do
        lines[#lines + 1] = {0, index * rowstep, 0, 0.5}
        lines[#lines + 1] = {canvas_size_w, index * rowstep, 0, 0.5}
    end
    local colstep = canvas_size_w / col
    for index = 1, col - 1 do
        lines[#lines + 1] = {index * colstep, 0, 0, 0.5}
        lines[#lines + 1] = {index * colstep, canvas_size_h, 0, 0.5}
    end
    grid[#grid + 1] = ientity.create_screen_line_list(lines, nil, {u_color = {0.3, 0.3, 0.3, 1.0}, u_canvas_size = {canvas_size_w, canvas_size_h, 0, 0} }, true, "translucent", queuename)
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
        total = 0,
        label_x = {"5s","4.5s","4.0s","3.5s","3.0s","2.5s","2.0s","1.5s","1.0s","0.5s"},
        label_y = {"8w ","7w ","6w ","5w ","4w ","3w ","2w ","1w "}
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
    local topheight = canvas_size_h * 0.875
    for count = 1, framecount do
        local frame = group.frames[index]
        line_list[line_idx][2] = (frame.power / totalframe[index].power) * topheight
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
        ivs.set_state(e, queuename, true)
        imaterial.set_property(e, "u_color", math3d.vector(color))
        update_vb(group.eid, line_list)
    else
        group.eid = ientity.create_screen_line_list(line_list, nil, {u_color = color, u_canvas_size = {canvas_size_w, canvas_size_h, 0, 0} }, true, "translucent", queuename)
        chart_eid[#chart_eid + 1] = group.eid
    end
    return color
end

local function gen_label_y(power)
    -- power is sum of 50 ticks
    -- frame ratio 30
    local persec = 30 / 50
    local total = power * persec
    local unit = "k"
    local divisor = 1000
    if total >= 1000000000 then
        divisor = 1000000000
        unit = "G"
    elseif total >= 1000000 then
        divisor = 1000000
        unit = "M"
    end
    total = total / divisor
    local step = total / 7
    local label = {}
    label[#label + 1] = ""--placehold
    for i = 1, 7 do
        label[#label + 1] = ("%.1f%s"):format(total-step*(i-1), unit)
    end
    return label
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
        create_grid(8, 10)
    end

    for _, _, _, type, value in statistics_mb:unpack() do
        if type == "filter_type" and filter_type ~= value then
            filter_type = value
            local label = {}
            local total_str, postfix = string.match(value,"(%d+)(%a)")
            local total = tonumber(total_str)
            local step = total / 10
            for i = 1, 10 do
                label[#label + 1] = (total-step*(i-1))..postfix
            end
            datamodel.label_x = label
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
            datamodel.label_y = gen_label_y(total.power)
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
            datamodel.label_y = gen_label_y(total.power)
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
    end
end
return M