local property_list = import_package "vaststars.prototype"("property_list")
local global = require "global"
local objects = global.objects
local cache_names = global.cache_names
local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"

local function format_vars(fmt, vars)
    return string.gsub(fmt, "%$([%w_]+)%$", vars)
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
        t.value = format_vars(cfg.value, entity)
        t.pos = cfg.pos

        r[#r + 1] = t
        ::continue::
    end
    table.sort(r, function(a, b) return a.pos < b.pos end)
    return r
end

local function get_property(e, typeobject)
    -- 显示建筑详细信息
    local t = {}
    if e.fluidbox and e.fluidbox.fluid ~= 0 then
        local pt = iprototype:query(e.fluidbox.fluid)
        t.fluid_name = pt.name

        local r = gameplay_core.fluidflow_query(e.fluidbox.fluid, e.fluidbox.id)
        if r then
            t.fluid_volume = r.volume / r.multiple
            t.fluid_capacity = r.capacity / r.multiple
            t.fluid_flow = r.flow / r.multiple
        end
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
            t[key] = value
            return t
        end

        for _, classify in ipairs {"in1","in2","in3","in4","out1","out2","out3"} do
            local fluid = e.fluidboxes[classify.."_fluid"]
            local id = e.fluidboxes[classify.."_id"]
            if fluid ~= 0 and id ~= 0 then
                local f = gameplay_core.fluidflow_query(fluid, id)
                if f then
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

local function get_detail_panel_property_list(object_id)
    local object = assert(objects:get(cache_names, object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return {}
    end

    local typeobject = iprototype:queryByName("entity", object.prototype_name)
    local entity = get_property(e, typeobject)

    return get_property_list(entity)
end

local function create(object_id)
    local object = assert(objects:get(cache_names, object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return {}
    end

    local typeobject = iprototype:queryByName("entity", object.prototype_name)

    return {
        object_id = object_id,
        detail_panel_icon = typeobject.icon,
        detail_panel_prototype = object.prototype_name,
        detail_panel_property_list = get_detail_panel_property_list(object_id),
    }
end

local function update(datamodel, param, object_id)
    assert(false)
end

local function tick(datamodel, param)
    local object_id = param[1]
    datamodel.detail_panel_property_list = get_detail_panel_property_list(object_id)
    return true
end

return {
    create = create,
    update = update,
    tick = tick,
}