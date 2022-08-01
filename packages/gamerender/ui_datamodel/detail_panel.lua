local property_list = import_package "vaststars.prototype"("property_list")
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local ichest = require "gameplay.interface.chest"
local gameplay_core = require "gameplay.core"

local building_detail = import_package "vaststars.prototype"("building_detail_config")

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
    return r
end

local function get_display_info(e, typeobject, t)
    local key = string.match(typeobject.name, "([^%u%d]+)")
    local tname = key and key or typeobject.name
    local detail = building_detail[tname]
    if not detail then
        return
    end
    local values = t.values;
    for _, propertyName in ipairs(detail) do
        local cfg = property_list[propertyName]
        if cfg.value then
            local cn, vn = string.match(cfg.value, "%$([%w_]*)%.?([%w_]*)%$")
            local raw_value
            if #vn > 0 then
                raw_value = e[cn][vn]
                values[cn.. "." .. vn] = raw_value
            else
                raw_value = typeobject[cn]
                if cn == "power" or cn == "drain" then
                    raw_value = raw_value * 50
                    local u = "kW"
                    local divisor = 1000
                    if raw_value >= 1000000000 then
                        divisor = 1000000000
                        u = "GW"
                    elseif raw_value >= 1000000 then
                        divisor = 1000000
                        u = "MW"
                    end
                    raw_value = raw_value / divisor
                    local v0, v1 = math.modf(raw_value)
                    if v1 > 0 then
                        raw_value = string.format("%.2f", raw_value) .. u
                    else
                        raw_value = string.format("%d", v0) .. u
                    end
                end
                values[cn] = raw_value
            end
        end
        t[propertyName] = cfg
    end
end
local function get_property(e, typeobject)
    local t = {
        values = {}
    }
    -- 显示建筑详细信息
    get_display_info(e, typeobject, t)
    if e.chest then
        local item_counts = ichest:item_counts(gameplay_core.get_world(), e)
        local slotnum = 0--t.values.slots
        local chest_list0 = {}
        local chest_list1 = {}
        for id, count in pairs(item_counts) do
            local typeobject_item = assert(iprototype.queryById(id))
            slotnum = slotnum + math.floor(count / typeobject_item.stack)
            if count % typeobject_item.stack > 0 then
                slotnum = slotnum + 1
            end
            if #chest_list0 < 5 then
                chest_list0[#chest_list0 + 1] = {icon = typeobject_item.icon, count = count}
            elseif #chest_list1 < 5 then
                chest_list1[#chest_list1 + 1] = {icon = typeobject_item.icon, count = count}
            end
        end
        t.chest_list0 = #chest_list0 > 0 and chest_list0 or nil
        t.chest_list1 = #chest_list1 > 0 and chest_list1 or nil
        t.values.slots = string.format("%d/%d", slotnum, t.values.slots)
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
                    local pt = iprototype.queryById(fluid)
                    if classify == "out1" then
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

local function get_entity_property_list(object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return {}
    end

    local typeobject = iprototype.queryByName("entity", object.prototype_name)
    local entity = get_property(e, typeobject)

    return get_property_list(entity)
end

---------------
local M = {}

function M:create(object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return {}
    end

    local typeobject = iprototype.queryByName("entity", object.prototype_name)
    local property_list = get_entity_property_list(object_id)
    local chest_list0 = property_list.chest_list0 or {}
    local chest_list1 = property_list.chest_list1 or {}
    property_list.chest_list0 = nil
    property_list.chest_list1 = nil
    return {
        object_id = object_id,
        icon = typeobject.icon,
        prototype_name = object.prototype_name,
        property_list = property_list,
        chest_list0 = chest_list0,
        chest_list1 = chest_list1
    }
end

function M:stage_ui_update(datamodel, object_id)
    local property_list = get_entity_property_list(object_id)
    local chest_list0 = property_list.chest_list0 or {}
    local chest_list1 = property_list.chest_list1 or {}
    property_list.chest_list0 = nil
    property_list.chest_list1 = nil
    datamodel.property_list = property_list
    datamodel.chest_list0 = chest_list0
    datamodel.chest_list1 = chest_list1
end

return M