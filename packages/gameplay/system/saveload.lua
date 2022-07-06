local system = require "register.system"
local luaecs = import_package "vaststars.ecs"
local json = import_package "ant.json"
local status = require "status"


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
        for _, c in ipairs(status.components) do
            writer:write(ecs, ecs:component_id(c.name))
        end
        local meta = writer:close()
        for i, c in ipairs(status.components) do
            meta[i].name = c.name
        end
        writeall(metafile, json.encode(meta))
    end
    function m.restore(world)
        local ecs = world.ecs
        local metafile = world.storage_path.."/ecs.json"
        local binfile = world.storage_path.."/ecs.bin"
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
        cworld:backup_container(world.storage_path.."/container.bin")
    end
    function m.restore(world)
        local cworld = world._cworld
        local metafile = world.storage_path.."/world.json"
        local binfile = world.storage_path.."/world.bin"
        local metajson = json.decode(readall(metafile))
        cworld:restore_world(binfile, metajson)
        cworld:restore_container(world.storage_path.."/container.bin")
    end
end
