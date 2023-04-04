local property_list = import_package "vaststars.prototype"("property_list")
local objects = require "objects"
local global = require "global"
local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"
local itypes = require "gameplay.interface.types"
local irecipe = require "gameplay.interface.recipe"
local ilaboratory = require "gameplay.interface.laboratory"
local ichest = require "gameplay.interface.chest"
local building_detail = import_package "vaststars.prototype"("building_detail_config")
local assembling_common = require "ui_datamodel.common.assembling"
local UPS <const> = require("gameplay.interface.constant").UPS

local function format_vars(fmt, vars)
    return string.gsub(fmt, "%$([%w%._]+)%$", vars)
end

local function get_property_list(entity)
    local r = {}
    for property_name in pairs(entity) do
        local cfg = property_list[property_name]
        if not cfg then
            goto continue
        end

        local t = {}
        t.icon = cfg.icon
        t.desc = cfg.desc
        t.value = cfg.value and format_vars(cfg.value, entity.values) or ""
        t.pos = cfg.pos

        r[#r + 1] = t
        ::continue::
    end
    table.sort(r, function(a, b) return a.pos < b.pos end)
    r.chest_list0 = entity.chest_list0
    r.chest_list1 = entity.chest_list1
    r.status = entity.status
    return r
end

local function get_solar_panel_power(total)
    local gameplayWorld = gameplay_core.get_world()
    local t = gameplayWorld:now() % 25000
    if t <= 6250 or t > 18750 then
        return total
    elseif t <= 11250  then
        return -total/5000 * t + total * (1 + 6250/5000)
    elseif t <= 13750 then
        return 0
    elseif t <= 18750 then
        return total/5000 * t - total * (6250 + 7500) / 5000
    end
end

local function get_display_info(e, typeobject, t)
    local key = string.match(typeobject.name, "([^%u%d]+)")
    local tname = key and key or typeobject.name
    local detail = building_detail[tname]
    if not detail then
        return
    end
    local values = t.values
    local status = 3 --work status
    for _, propertyName in ipairs(detail) do
        local cfg = property_list[propertyName]
        if cfg.value then
            local cn, vn = string.match(cfg.value, "%$([%w_]*)%.?([%w_]*)%$")
            local total
            local key = cn
            if #vn > 0 then
                total = e[cn][vn]
                key = cn.. "." .. vn
            else
                total = typeobject[cn]
                if cn == "power" or cn == "capacitance" then
                    local current = 0
                    if cn == "power" then
                        local st = global.statistic["power"][e.eid]
                        -- if typeobject.name == "指挥中心" then
                        --     local consumenode = global.statistic.power_consumed["5s"]
                        --     current = consumenode.power / consumenode.time
                        -- else
                        if st then
                            -- power is sum of 50 tick
                            current = st[cn] * (UPS / 50)
                        elseif e.solar_panel then
                            current = get_solar_panel_power(total) * UPS
                            if current <= 0 then
                                status = 1 --shundown status
                            end
                        end
                        if typeobject.drain then
                            if current <= 0 then
                                status = 1 --shundown status
                            elseif current <= typeobject.drain * UPS then
                                status = 2 --idle status
                            end
                        end
                    end
                    total = total * UPS
                    local unit = "k"
                    local divisor = 1000
                    if total >= 1000000000 then
                        divisor = 1000000000
                        unit = "G"
                    elseif total >= 1000000 then
                        divisor = 1000000
                        unit = "M"
                    end
                    unit = unit..((cn == "capacitance") and "J" or "W")
                    total = total / divisor
                    current = current / divisor

                    local function format(value, u)
                        local v0, v1 = math.modf(value)
                        if v1 > 0 then
                            return string.format("%.2f", value) .. u
                        else
                            return string.format("%d", v0) .. u
                        end
                    end
                    total = format(current, unit) .. "/" .. format(total, unit)
                elseif cn == "speed" then
                    total = total * 100
                end
            end
            if cn == "speed" or vn == "speed" then
                total = string.format("%d%%", total)
            end
            values[key] = total
        end
        t[propertyName] = cfg
    end
    t.status = status
end
local function get_property(e, typeobject)
    local t = {
        values = {}
    }
    -- 显示建筑详细信息
    get_display_info(e, typeobject, t)
    if e.chest and e.chest.id == e.chest.id and e.chest.id ~= 0xffff then
        local slotnum = 0
        -- the items display is shown in two rows, with list0 for the first row and list1 for the second row (five items per row, up to ten items in total)
        local chest_list0 = {}
        local chest_list1 = {}
        local typeobject = iprototype.queryById(e.building.prototype)
        if typeobject.slots then
            for _, slot in pairs(ichest.collect_item(gameplay_core.get_world(), e)) do
                local typeobject_item = assert(iprototype.queryById(slot.item))
                slotnum = slotnum + math.floor(slot.amount / typeobject_item.stack)
                if slot.amount % typeobject_item.stack > 0 then
                    slotnum = slotnum + 1
                end
                if #chest_list0 < 5 then
                    chest_list0[#chest_list0 + 1] = {icon = typeobject_item.icon, count = slot.amount}
                elseif #chest_list1 < 5 then
                    chest_list1[#chest_list1 + 1] = {icon = typeobject_item.icon, count = slot.amount}
                end
            end
            t.chest_list0 = #chest_list0 > 0 and chest_list0 or nil
            t.chest_list1 = #chest_list1 > 0 and chest_list1 or nil
            t.values.slots = string.format("%d/%d", slotnum, t.values.slots or 0)
        end
    end
    if e.fluidbox then
        local name = "无"
        local volume = 0
        local capacity = 0
        local flow = 0
        if e.fluidbox.fluid ~= 0 then
            local pt = iprototype.queryById(e.fluidbox.fluid)
            name = pt.name

            local r = gameplay_core.fluidflow_query(e.fluidbox.fluid, e.fluidbox.id)
            if r then
                volume = r.volume / r.multiple
                capacity = r.capacity / r.multiple
                flow = r.flow / r.multiple
            end
        end
        t.values.fluid_name = name
        t.values.fluid_volume = volume
        t.values.fluid_capacity = capacity
        t.values.fluid_flow = flow
    end

    if e.fluidboxes then
        local fluidboxes_type_str = {
            ["out"] = "output",
            ["in"] = "input",
        }

        local function add_property(t, key, value)
            if value == 0 then
                return t
            end
            t.values[key] = value
            return t
        end

        for _, classify in ipairs {"in1","in2","in3","in4","out1","out2","out3"} do
            local fluid = e.fluidboxes[classify.."_fluid"]
            local id = e.fluidboxes[classify.."_id"]
            if fluid ~= 0 and id ~= 0 then
                local f = gameplay_core.fluidflow_query(fluid, id)
                if f then
                    if classify == "out1" then
                        local pt = iprototype.queryById(fluid)
                        -- only show out1 detail
                        add_property(t, "fluid_name", pt.name)
                        add_property(t, "fluid_volume", f.volume / f.multiple)
                        add_property(t, "fluid_capacity", f.capacity / f.multiple)
                    end
                    add_property(t, "fluidboxes_" .. classify .. "_volume", f.volume / f.multiple)
                    add_property(t, "fluidboxes_" .. classify .. "_capacity", f.capacity / f.multiple)
                    add_property(t, "fluidboxes_" .. classify .. "_flow", f.flow / f.multiple)

                    local fluidboxes_type, fluidboxes_index = classify:match("(%l*)(%d*)")
                    local cfg = typeobject.fluidboxes[fluidboxes_type_str[fluidboxes_type]][tonumber(fluidboxes_index)]

                    add_property(t, "fluidboxes_" .. classify .. "_base_level", cfg.base_level)
                    add_property(t, "fluidboxes_" .. classify .. "_height", cfg.height)
                end
            end
        end
    end
    return t
end

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

local function get_entity_property_list(object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return {}
    end

    local typeobject = iprototype.queryByName(object.prototype_name)

    local entity = get_property(e, typeobject)
    local property_list = get_property_list(entity)
    if e.assembling then
        local total_progress = 0
        local progress = 0
        if e.assembling.recipe ~= 0 then
            local recipe_typeobject = assert(iprototype.queryById(e.assembling.recipe))
            total_progress = recipe_typeobject.time * 100
            progress = e.assembling.progress
            property_list.recipe_name = recipe_typeobject.name
            property_list.recipe_inputs, property_list.recipe_ouputs = assembling_common.get(gameplay_core.get_world(), e)
        
            if e.assembling.status == STATUS_IDLE then
                property_list.progress = "0%"
            else
                property_list.progress = itypes.progress_str(progress, total_progress)
            end
            if e.mining then
                property_list.is_minner = true
            else
                property_list.is_assemble = true
            end
        end
    elseif e.laboratory then
        local current_inputs = ilaboratory:get_elements(typeobject.inputs)
        local items = {}
        for i, value in ipairs(current_inputs) do
            local slot = ichest.chest_get(gameplay_core.get_world(), e.chest, i)
            items[#items+1] = {icon = value.icon, count = slot.amount or 0}
        end
        property_list.chest_list0 = items
    end
    return property_list
end

---------------
local detail_panel_status_icon = {"textures/work_status_icon/out_of_power.texture","textures/work_status_icon/idle.texture","textures/work_status_icon/normal.texture"}
local detail_panel_status_desc = {"断电停机", "待机空闲", "正常工作"}
local M = {}
local update_interval = 25 --update per 25 frame
local counter = 1
local function update_property_list(datamodel, property_list)
    datamodel.chest_list0 = property_list.chest_list0 or {}
    datamodel.chest_list1 = property_list.chest_list1 or {}
    datamodel.show_chest = #datamodel.chest_list0 > 0
    datamodel.progress = property_list.progress or "0%"
    datamodel.recipe_inputs = property_list.recipe_inputs or {}
    datamodel.recipe_ouputs = property_list.recipe_ouputs or {}
    datamodel.show_minner = property_list.is_minner
    datamodel.show_assemble = property_list.is_assemble
    datamodel.recipe_name = property_list.recipe_name
    local status = property_list.status
    datamodel.detail_panel_status_icon = detail_panel_status_icon[status]
    datamodel.detail_panel_status_desc = detail_panel_status_desc[status]
    property_list.chest_list0 = nil
    property_list.chest_list1 = nil
    property_list.progress = nil
    property_list.recipe_inputs = nil
    property_list.recipe_ouputs = nil
    property_list.status = nil
    property_list.recipe_name = nil
    datamodel.property_list = property_list
end
function M:create(object_id)
    counter = update_interval
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return {}
    end

    local typeobject = iprototype.queryByName(object.prototype_name)
    local datamodel = {
        object_id = object_id,
        icon = typeobject.icon,
        prototype_name = iprototype.show_prototype_name(typeobject)
    }
    update_property_list(datamodel, get_entity_property_list(object_id))
    return datamodel
end

function M:stage_ui_update(datamodel, object_id)
    counter = counter + 1
    if counter < update_interval then
        return
    end
    counter = 1
    update_property_list(datamodel, get_entity_property_list(object_id))
end

return M