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
    function m.backup(world, rootdir)
        local ecs = world.ecs
        local metafile = rootdir.."/ecs.json"
        local binfile = rootdir.."/ecs.bin"
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
    function m.restore(world, rootdir)
        local ecs = world.ecs
        local metafile = rootdir.."/ecs.json"
        local binfile = rootdir.."/ecs.bin"
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
    function m.backup(world, rootdir)
        local f = rootdir.."/storage.json"
        writeall(f, json.encode(world.storage))
    end
    function m.restore(world, rootdir)
        local f = rootdir.."/storage.json"
        world.storage = json.decode(readall(f))
    end
end
