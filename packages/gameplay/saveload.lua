local luaecs = import_package "vaststars.ecs"
local json = import_package "ant.json"
local status = require "status"
local fs = require "bee.filesystem"

local m = {}

local function writeall(file, content)
    local f <close> = assert(io.open(file, "wb"))
    f:write(content)
end

local function readall(file)
    local f <close> = assert(io.open(file, "rb"))
    return f:read "a"
end

local function ecs_backup(ecs, metafile, binfile)
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

local function ecs_restore(ecs, metafile, binfile)
    local reader = luaecs.reader(binfile)
    for _, meta in ipairs(json.decode(readall(metafile))) do
        ecs:read_component(reader, meta.name, meta.offset, meta.stride, meta.n)
    end
    reader:close()
end

function m.backup(ecs, rootdir)
    fs.create_directories(rootdir)
    ecs_backup(ecs, rootdir.."/ecs.json", rootdir.."/ecs.bin")
end

function m.restore(ecs, rootdir)
    ecs_restore(ecs, rootdir.."/ecs.json", rootdir.."/ecs.bin")
end

return m
