local ecs   = ...
local world = ecs.world
local w     = world.w

local iBackpack = import_package "vaststars.gameplay".interface "backpack"
local gameplay_core = require "gameplay.core"
local iprototype = ecs.require "gameplay.interface.prototype"
local irecipe = ecs.require "gameplay.interface.recipe"
local ichest = require "gameplay.interface.chest"
local imineral = ecs.require "mineral"

local funcs = {}
funcs["base"] = function(world, e, info)
    world.ecs:extend(e, "base?in")
    if not e.base then
        return info
    end
    info.amount = 0
    return info
end

funcs["building"] = function(world, e, info)
    info.prototype_name = iprototype.queryById(e.building.prototype).name
    info.dir = iprototype.dir_tostring(e.building.direction)
    info.x = e.building.x
    info.y = e.building.y
    return info
end

funcs["assembling"] = function(world, e, info)
    world.ecs:extend(e, "assembling?in")
    if not e.assembling then
        return info
    end
    if e.assembling.recipe ~= 0 then
        local typeobject = iprototype.queryById(e.assembling.recipe)
        info.recipe = typeobject.name
        info.fluid_name = irecipe.get_init_fluids(typeobject)
    else
        info.fluid_name = ""
    end
    return info
end

funcs["fluidbox"] = function(world, e, info)
    world.ecs:extend(e, "fluidbox?in")
    if not e.fluidbox then
        return info
    end
    if e.fluidbox.fluid ~= 0 and e.fluidbox.id ~= 0 then
        local typeobject = iprototype.queryById(e.fluidbox.fluid)
        info.fluid_name = typeobject.name
    else
        info.fluid_name = ""
    end
    return info
end

funcs["chimney"] = function(world, e, info)
    world.ecs:extend(e, "chimney?in")
    if not e.chimney then
        return info
    end
    if e.chimney.recipe ~= 0 then
        info.recipe = iprototype.queryById(e.chimney.recipe).name
    end
    return info
end

funcs["chest"] = function(world, e, info)
    world.ecs:extend(e, "chest?in")
    if not e.chest then
        return info
    end

    local typeobject = iprototype.queryById(e.building.prototype)
    if not iprototype.has_type(typeobject.type, "chest") then
        return info
    end

    local items = {}
    for i = 1, ichest.MAX_SLOT do
        local slot = ichest.get(world, e.chest, i)
        if not slot then
            break
        end

        local amount = ichest.get_amount(slot)
        if slot.item ~= 0 and amount ~= 0 then
            items[#items+1] = {iprototype.queryById(slot.item).name, amount}
        end
    end

    info.items = items
    return info
end

funcs["station"] = function(world, e, info)
    world.ecs:extend(e, "station?in")
    if not e.station then
        return info
    end
    local items = {}
    for i = 1, ichest.MAX_SLOT do
        local slot = ichest.get(world, e.station, i)
        if not slot then
            break
        end
        items[#items+1] = {slot.type, slot.item == 0 and "" or assert(iprototype.queryById(slot.item)).name, slot.limit}
    end
    info.items = items
    return info
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
    local gameplay_world = gameplay_core.get_world()
    local gameplay_ecs = gameplay_world.ecs

    local entities = {}
    for e in gameplay_ecs:select "building:in road:absent" do
        local typeobject = iprototype.queryById(e.building.prototype)
        local info = {prototype_name = typeobject.name}
        for _, func in pairs(funcs) do
            info = func(gameplay_world, e, info)
        end
        entities[#entities+1] = info
    end

    local roads = {}
    for e in gameplay_ecs:select "building:in road:in" do
        roads[#roads+1] = {
            x = e.building.x,
            y = e.building.y,
            prototype_name = iprototype.queryById(e.building.prototype).name,
            dir = iprototype.dir_tostring(e.building.direction),
        }
    end

    local backpack = {}
    for _, slot in pairs(iBackpack.all(gameplay_world)) do
        local typeobject_item = assert(iprototype.queryById(slot.prototype))
        backpack[#backpack+1] = {
            prototype_name = typeobject_item.name,
            count = slot.amount
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
        inspect(imineral.source())
    ))

    log.info("export entity success")
end
