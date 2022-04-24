local vaststars = require "vaststars.world.core"
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

function m.backup(rootdir, cworld, ecs)
    fs.create_directories(rootdir)
    ecs_backup(ecs, rootdir.."/ecs.json", rootdir.."/ecs.bin")

    local f <close> = assert(io.open(rootdir.."/world.bin", "wb"))
    vaststars.backup_world(cworld, f)
end

function m.restore(rootdir, cworld, ecs)
    local f <close> = assert(io.open(rootdir.."/world.bin", "rb"))
    vaststars.restore_world(cworld, f)

    ecs:clearall()
    ecs_restore(ecs, rootdir.."/ecs.json", rootdir.."/ecs.bin")
    for v in ecs:select "fluidbox fluidbox_changed?out" do
        v.fluidbox_changed = true
    end
    for v in ecs:select "fluidboxes fluidbox_changed?out" do
        v.fluidbox_changed = true
    end
    ecs:update()
end

return m
