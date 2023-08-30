local system = require "register.system"
local luaecs = import_package "ant.luaecs"
local json = import_package "ant.json"

local function writeall(file, content)
    local f <close> = assert(io.open(file, "wb"))
    f:write(content)
end

local function readall(file)
    local f <close> = assert(io.open(file, "rb"))
    return f:read "a"
end

do
    local m = system "saveload-ecs"
    function m.backup(world)
        local ecs = world.ecs
        local metafile = world.storage_path.."/ecs.json"
        local binfile = world.storage_path.."/ecs.bin"
        local writer = luaecs.writer(binfile)
        local components = {
            "eid",
            "REMOVED",
        }
        for _, c in ipairs(require "register.component") do
            components[#components+1] = c.name
        end
        for _, name in ipairs(components) do
            writer:write(ecs, ecs:component_id(name))
        end
        local meta = writer:close()
        for i, name in ipairs(components) do
            meta[i].name = name
        end
        writeall(metafile, json.encode(meta))
    end
    function m.restore(world)
        local ecs = world.ecs
        local metafile = world.storage_path.."/ecs.json"
        local binfile = world.storage_path.."/ecs.bin"
        world:visitor_clear()
        ecs:clearall()
        local reader = luaecs.reader(binfile)
        for _, meta in ipairs(json.decode(readall(metafile))) do
            ecs:read_component(reader, meta.name, meta.offset, meta.stride, meta.n)
        end
        reader:close()
    end
end

do
    local m = system "saveload-storage"
    function m.backup(world)
        local f = world.storage_path.."/storage.json"
        writeall(f, json.encode(world.storage))
    end
    function m.restore(world)
        local f = world.storage_path.."/storage.json"
        world.storage = json.decode(readall(f))
    end
end

do
    local m = system "saveload-world"
    function m.backup(world)
        local cworld = world._cworld
        local metafile = world.storage_path.."/world.json"
        local binfile = world.storage_path.."/world.bin"
        writeall(metafile, json.encode(cworld:backup_world(binfile)))
    end
    function m.restore(world)
        local cworld = world._cworld
        local metafile = world.storage_path.."/world.json"
        local binfile = world.storage_path.."/world.bin"
        local metajson = json.decode(readall(metafile))
        cworld:restore_world(binfile, metajson)
    end
end
do
    local m = system "saveload-prototype"
    function m.backup(world)
        local prototype = require "prototype"
        local metafile = world.storage_path.."/prototype.json"
        writeall(metafile, json.encode(prototype.backup()))
    end
    function m.restore(world)
        local cworld = world._cworld
        local prototype = require "prototype"
        local metafile = world.storage_path.."/prototype.json"
        prototype.restore(cworld, json.decode(readall(metafile)))
    end
end
