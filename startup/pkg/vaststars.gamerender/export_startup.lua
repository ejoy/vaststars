local gameplay_core = import_package "vaststars.gamerender"("gameplay.core")
local iprototype = import_package "vaststars.gamerender"("gameplay.interface.prototype")
local irecipe = import_package "vaststars.gamerender"("gameplay.interface.recipe")
local ichest = require "gameplay.interface.chest"

local function DO_NOTHING(export_data)
    return export_data
end

local funcs = {}
funcs["item"] = DO_NOTHING
funcs["recipe"] = DO_NOTHING

funcs["consumer"] = DO_NOTHING
funcs["fluidboxes"] = DO_NOTHING -- usually only assembler has fluidboxes, handle it uniformly in assembling type
funcs["pipe"] = DO_NOTHING -- pipes are typically represented by fluidboxes and should be handled in the fluidbox type
funcs["generator"] = DO_NOTHING
funcs["inserter"] = DO_NOTHING
funcs["pole"] = DO_NOTHING
funcs["laboratory"] = DO_NOTHING
funcs["base"] = DO_NOTHING
funcs["mining"] = DO_NOTHING
funcs["solar_panel"] = DO_NOTHING
funcs["road"] = DO_NOTHING
funcs["station"] = DO_NOTHING
funcs["lorry_factory"] = DO_NOTHING
funcs["hub"] = DO_NOTHING
funcs["wind_turbine"] = DO_NOTHING
funcs["accumulator"] = DO_NOTHING

funcs["building"] = function (export_data, e)
    export_data.prototype_name = iprototype.queryById(e.building.prototype).name
    export_data.dir = iprototype.dir_tostring(e.building.direction)
    export_data.x = e.building.x
    export_data.y = e.building.y
    return export_data
end

funcs["assembling"] = function (export_data, e)
    gameplay_core.extend(e, "assembling?in")
    if e.assembling.recipe ~= 0 then
        local typeobject = iprototype.queryById(e.assembling.recipe)
        export_data.recipe = typeobject.name
        export_data.fluids = irecipe.get_init_fluids(typeobject)
    else
        export_data.fluids = ""
    end
    return export_data
end

funcs["fluidbox"] = function (export_data, e)
    gameplay_core.extend(e, "fluidbox?in")
    if e.fluidbox.fluid ~= 0 and e.fluidbox.id ~= 0 then
        local typeobject = iprototype.queryById(e.fluidbox.fluid)
        export_data.fluid = typeobject.name
    else
        export_data.fluid = ""
    end
    return export_data
end

funcs["chimney"] = function (export_data, e)
    gameplay_core.extend(e, "chimney?in")
    if e.chimney.recipe ~= 0 then
        local typeobject = iprototype.queryById(e.chimney.recipe)
        export_data.recipe = typeobject.name
        export_data.fluids = irecipe.get_init_fluids(typeobject)
    else
        export_data.fluids = ""
    end
    return export_data
end

funcs["chest"] = function (export_data, e)
    gameplay_core.extend(e, "chest?in building?in")
    local items = {}
    for _, slot in pairs(ichest.collect_item(gameplay_core.get_world(), e)) do
        items[#items+1] = {iprototype.queryById(slot.item).name, slot.amount}
    end

    export_data.items = items
    return export_data
end

local function writeall(file, content)
    local f <close> = assert(io.open(file, "wb"))
    f:write(content)
end

local function writefile(content)
    local fs = require "bee.filesystem"
    local path = (fs.exe_path():replace_extension("") / "../../../../startup/mod/pkg/vaststars.prototype/item/"):string()
    fs.create_directories(path)
    local f = (fs.exe_path():replace_extension("") / "../../../../startup/mod/pkg/vaststars.prototype/item/startup.lua"):string()
    writeall(f, content)
end

local inspect = require "inspect"
return function()
    log.info("export entity")

    local r = {}
    for v in gameplay_core.select("building:in") do
        local building = v.building
        local typeobject = iprototype.queryById(building.prototype)
        local prototype_name, export_data = typeobject.name, {}

        for _, t in ipairs(typeobject.type) do
            local func = assert(funcs[t], ("unknown type %s"):format(t))
            export_data = func(export_data, v)
        end
        export_data.prototype_name = prototype_name
        r[#r+1] = export_data
    end
    writefile(([[
local entities = %s
local road = {}

return {
    entities = entities,
    road = road,
}
    ]]):format(inspect(r)))
end
