local ecs   = ...
local world = ecs.world
local w     = world.w

local iBackpack = import_package "vaststars.gameplay".interface "backpack"
local gameplay_core = import_package "vaststars.gamerender"("gameplay.core")
local iprototype = import_package "vaststars.gamerender"("gameplay.interface.prototype")
local irecipe = import_package "vaststars.gamerender"("gameplay.interface.recipe")
local ichest = require "gameplay.interface.chest"
local terrain = ecs.require "terrain"

local function DO_NOTHING(entity)
    return entity
end

local funcs = {}
funcs["item"] = DO_NOTHING
funcs["recipe"] = DO_NOTHING
funcs["consumer"] = DO_NOTHING
funcs["fluidboxes"] = DO_NOTHING -- usually only assembler has fluidboxes, handle it uniformly in assembling type
funcs["pipe"] = DO_NOTHING -- pipes are typically represented by fluidbox and should be handled in the fluidbox type
funcs["pipe_to_ground"] = DO_NOTHING -- pipes are typically represented by fluidbox and should be handled in the fluidbox type
funcs["generator"] = DO_NOTHING
funcs["inserter"] = DO_NOTHING
funcs["pole"] = DO_NOTHING
funcs["laboratory"] = DO_NOTHING
funcs["mining"] = DO_NOTHING
funcs["solar_panel"] = DO_NOTHING
funcs["road"] = DO_NOTHING
funcs["factory"] = DO_NOTHING
funcs["wind_turbine"] = DO_NOTHING
funcs["accumulator"] = DO_NOTHING
funcs["auto_set_recipe"] = DO_NOTHING
funcs["park"] = DO_NOTHING
funcs["airport"] = DO_NOTHING

funcs["base"] = function(entity)
    entity.items = {{"运输车辆I", 50}}
    return entity
end

funcs["building"] = function (entity, e)
    entity.prototype_name = iprototype.queryById(e.building.prototype).name
    entity.dir = iprototype.dir_tostring(e.building.direction)
    entity.x = e.building.x
    entity.y = e.building.y
    return entity
end

funcs["assembling"] = function (entity, e)
    gameplay_core.extend(e, "assembling?in")
    if e.assembling.recipe ~= 0 then
        local typeobject = iprototype.queryById(e.assembling.recipe)
        entity.recipe = typeobject.name
        entity.fluid_name = irecipe.get_init_fluids(typeobject)
    else
        entity.fluid_name = ""
    end
    return entity
end

funcs["fluidbox"] = function (entity, e)
    gameplay_core.extend(e, "fluidbox?in")
    if e.fluidbox.fluid ~= 0 and e.fluidbox.id ~= 0 then
        local typeobject = iprototype.queryById(e.fluidbox.fluid)
        entity.fluid_name = typeobject.name
    else
        entity.fluid_name = ""
    end
    return entity
end

funcs["chimney"] = function (entity, e)
    gameplay_core.extend(e, "chimney?in")
    if e.chimney.recipe ~= 0 then
        entity.recipe = iprototype.queryById(e.chimney.recipe).name
    end
    return entity
end

funcs["chest"] = function (entity, e)
    gameplay_core.extend(e, "chest?in building?in")
    local items = {}
    for i = 1, ichest.MAX_SLOT do
        local slot = ichest.get(gameplay_core.get_world(), e.chest, i)
        if not slot then
            break
        end

        local amount = ichest.get_amount(slot)
        if slot.item ~= 0 and amount ~= 0 then
            items[#items+1] = {iprototype.queryById(slot.item).name, amount}
        end
    end

    entity.items = items
    return entity
end

funcs["station"] = function (entity, e)
    gameplay_core.extend(e, "station?in")
    local items = {}
    for i = 1, ichest.MAX_SLOT do
        local slot = ichest.get(gameplay_core.get_world(), e.station, i)
        if not slot then
            break
        end
        items[#items+1] = {slot.type, slot.item == 0 and "" or assert(iprototype.queryById(slot.item)).name, slot.limit}
    end
    entity.items = items
    return entity
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

    local entities = {}
    for v in gameplay_core.select("building:in road:absent") do
        local typeobject = iprototype.queryById(v.building.prototype)
        local entity = {prototype_name = typeobject.name}
        for _, t in ipairs(typeobject.type) do
            local func = assert(funcs[t], ("unknown type %s"):format(t))
            entity = func(entity, v)
        end
        entities[#entities+1] = entity
    end

    local backpack = {}
    for _, slot in pairs(iBackpack.all(gameplay_core.get_world())) do
        local typeobject_item = assert(iprototype.queryById(slot.prototype))
        backpack[#backpack+1] = {
            prototype_name = typeobject_item.name,
            count = slot.amount
        }
    end

    local roads = {}
    for v in gameplay_core.select("building:in road:in") do
        roads[#roads+1] = {
            x = v.building.x,
            y = v.building.y,
            prototype_name = iprototype.queryById(v.building.prototype).name,
            dir = iprototype.dir_tostring(v.building.direction),
        }
    end

    writefile(([[
local entities = %s
local backpack = %s
local road = %s
local mineral = %s

return {
    entities = entities,
    backpack = backpack,
    road = road,
    mineral = mineral,
}
    ]]):format(
        inspect(entities),
        inspect(backpack),
        inspect(roads),
        inspect(terrain.mineral_source)
    ))
end
