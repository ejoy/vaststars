local ecs   = ...
local world = ecs.world
local w     = world.w

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

funcs["factory"] = function(world, e, info)
    world.ecs:extend(e, "factory?in")
    if not e.factory then
        return info
    end
    info.amount = 50
    return info
end

funcs["debris"] = function(world, e, info)
    world.ecs:extend(e, "debris?in")
    if not e.debris then
        return info
    end
    info.debris = e.debris.prototype
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

    world.ecs:extend(e, "station?in")
    if e.station then
        return info
    end

    local items = {}
    for i = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(world, e.chest, i)
        if not slot then
            break
        end

        items[#items+1] = {(slot.item ~= 0) and iprototype.queryById(slot.item).name or 0, ichest.get_amount(slot)}
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
    for i = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(world, e.station, i)
        if not slot then
            break
        end
        items[#items+1] = {slot.type, (slot.item ~= 0) and iprototype.queryById(slot.item).name or "", slot.limit}
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

local inspect = require "utility.inspect"
return function()
    log.info("export entity")
    local gameplay_world = gameplay_core.get_world()
    local gameplay_ecs = gameplay_world.ecs

    local entities = {}
    for e in gameplay_ecs:select "building:in road:absent park:absent" do
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

    local file = assert(gameplay_core.get_storage().game_template)
    local template = ecs.require(("vaststars.prototype|%s"):format(file))

    writefile(([[
local guide = require "guide.guide5"
local mountain = require "mountain"

local mountain = {
    density = 0.1,
    mountain_coords = {},
    excluded_rects = {
    {0, 0, 255, 255},
    },
}

local entities = %s
local road = %s
local mineral = %s

return {
    name = "%s",
    entities = entities,
    road = road,
    mineral = mineral,
    mountain = mountain,
    order = %d,
    guide = guide,
    show = true,
    start_tech = "%s",
    performance_stats = %s,
    canvas_icon = %s,
    init_ui = %s,
    init_instances = %s,
    game_settings = %s,
    camera = "%s",
}
    ]]):format(
        inspect(entities),
        inspect(roads),
        inspect(imineral.source()),
        template.name,
        template.order,
        template.start_tech,
        tostring(template.performance_stats),
        tostring(template.canvas_icon),
        inspect(template.init_ui),
        inspect(template.init_instances),
        inspect(template.game_settings, {indent="\t\t\t"}),
        template.camera
    ))

    log.info("export entity success")
end
