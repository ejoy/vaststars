local gameplay = import_package "vaststars.gameplay"
local fs = require "bee.filesystem"

local function __create_gameplay_world()
    local world = gameplay.createWorld()
    return world
end

local function __writeall(file, content)
    local parent = fs.path(file):parent_path()
    if not fs.exists(parent) then
        fs.create_directories(parent)
    end
    local f <close> = assert(io.open(file, "wb"))
    f:write(content)
end

local function __readall(file)
    local f <close> = assert(io.open(file, "rb"))
    return f:read "a"
end

local world = __create_gameplay_world()
local irecipe = require "gameplay.interface.recipe"
local iprototype = require "gameplay.interface.prototype"
local MULTIPLE <const> = require "debugger".multiple
local directory = require "directory"

local CUSTOM_ARCHIVING <const> = require "debugger".custom_archiving
local ARCHIVAL_BASE_DIR
if CUSTOM_ARCHIVING then
    ARCHIVAL_BASE_DIR = (fs.exe_path():parent_path() / CUSTOM_ARCHIVING):lexically_normal():string()
else
    ARCHIVAL_BASE_DIR = (directory.app_path "vaststars" / "archiving/"):string()
end
local GLOBAL_SETTINGS_FILENAME <const> = ARCHIVAL_BASE_DIR .. "settings.json"
local json = import_package "ant.json"

local m = {}
m.world_update = false
m.multiple = MULTIPLE or 1
m.system_changed_flags = 0

function m.select(...)
    return world.ecs:select(...)
end

function m.extend(...)
    return world.ecs:extend(...)
end

function m.update()
    for _ = 1, m.multiple do
        world:update()
    end
end

function m.set_multiple(n)
    m.multiple = n
end

function m.is_researched(...)
    return world:is_researched(...)
end

local create_entity_cache = {}
local function create(world, prototype, entity)
    if not create_entity_cache[prototype] then
        create_entity_cache[prototype] = world:create_entity(prototype)
        if not create_entity_cache[prototype] then
            log.error(("failed to create entity `%s`"):format(prototype))
            return
        end
    end
    return create_entity_cache[prototype](entity)
end

local init_func = {}
init_func["assembling"] = function(pt, template)
    local recipe = pt.recipe or template.recipe
    if pt.recipe and template.recipe then
        assert(pt.recipe == template.recipe) -- when both are set, they must be the same
    end

    if not recipe then
        return template
    end

    template.fluids = template.fluid -- TODO: remove this
    return template
end

init_func["chimney"] = function (pt, template)
    if not template.recipe then
        return template
    end

    local typeobject = iprototype.queryByName(template.recipe)
    template.fluids = irecipe.get_init_fluids(typeobject)

    return template
end

init_func["road"] = function (pt, template)
    return template
end

local post_funcs = {}

function m.create_entity(init)
    -- assert(not(init.x == 0 and init.y == 0))
    local func
    local template = {
        x = init.x,
        y = init.y,
        dir = init.dir,
        fluid = init.fluid_name,
        items = init.items,
        item = init.item,
        recipe = init.recipe, -- for debugging
        amount = init.amount,
    }

    local typeobject = iprototype.queryByName(init.prototype_name)
    for _, entity_type in ipairs(typeobject.type) do
        func = init_func[entity_type]
        if func then
            template = assert(func(typeobject, template))
        end
        func = post_funcs[entity_type]
        if func then
            func(typeobject, template)
        end
    end

    local eid = create(world, init.prototype_name, template)
    -- print("gameplay create_entity", init.prototype_name, template.dir, template.x, template.y, template.fluid or "[fluid]", template.recipe or "[recipe]", eid)
    return eid
end

function m.fluidflow_query(...)
    return world:fluidflow_query(...)
end

function m.get_entity(eid)
    return world.entity[eid]
end

function m.get_world()
    return world
end

function m.debug_entity(eid)
    return world.ecs:readall(eid)
end

function m.backup(rootdir)
    return world:backup(rootdir)
end

function m.restore(rootdir)
    world:restore(rootdir)
end

function m.restart()
    create_entity_cache = {}
    world = __create_gameplay_world()
end

function m.get_storage(key, defvalue)
    world.storage = world.storage or {}
    if not key then
        return world.storage
    else
        if world.storage[key] == nil then
            return defvalue
        else
            return world.storage[key]
        end
    end
end

function m.set_changed(flag)
    m.system_changed_flags = m.system_changed_flags | flag
end

function m.settings_get(k, def)
    if not fs.exists(fs.path(GLOBAL_SETTINGS_FILENAME)) then
        return def
    end
    local global_settings = json.decode(__readall(GLOBAL_SETTINGS_FILENAME))
    if global_settings[k] == nil then
        return def
    end
    return global_settings[k]
end

function m.settings_set(k, v)
    local global_settings = {}
    if fs.exists(fs.path(GLOBAL_SETTINGS_FILENAME)) then
        global_settings = json.decode(__readall(GLOBAL_SETTINGS_FILENAME))
    end
    global_settings[k] = v
    __writeall(GLOBAL_SETTINGS_FILENAME, json.encode(global_settings))
end

return m