local ecs = ...

local iui = ecs.import.interface "vaststars.gamerender|iui"
local assetmgr = import_package "ant.asset"
local serialize = import_package "ant.serialize"
local vfs = require "vfs"
local ltask = require "ltask"
local fs = require "filesystem"

local M = {}
local WorkerNum <const> = 6
local status

local BlackList <const> = {
    ["/pkg/vaststars.mod.test"] = true,
    ["/pkg/ant.bake"] = true,
    ["/pkg/ant.resources.binary/meshes/cloud.glb"] = true,
}

local function status_addtask(task)
    if BlackList[task.filename] then
        return
    end
    if task.type == "dir" then
        table.insert(status.pending, 1, task)
    else
        table.insert(status.pending, task)
    end
end

local function status_finish()
    if #status.pending == 0 and status.loading == 0 then
        return true
    end
    if status.stop then
        return true
    end
end

local function status_stopped()
    for _, v in ipairs(status) do
        if v ~= "" then
            return
        end
    end
    return true
end

local function touch_res(r)
    local _ = #r
end

local function readall(path)
    local realpath = assert(vfs.realpath(path))
    local f <close> = assert(io.open(realpath))
    return f:read "a"
end

local handler = {}

function handler.prefab(f)
    local prefab_data = readall(f)
    for _, e in ipairs(serialize.parse(f, prefab_data)) do
        if e.prefab then -- TODO: special case for prefab
            goto continue
        end
        local data = e.data
        if data.material then
            status_addtask {
                type = "material",
                filename = data.material,
            }
        end
        if data.animation then
            for _, v in pairs(data.animation) do
                status_addtask {
                    type = "resource",
                    filename = v,
                }
                status_addtask {
                    type = "file",
                    filename = v:match("^(.+%.).*$") .. "event",
                }
            end
        end
        if data.mesh then
            status_addtask {
                type = "resource",
                filename = data.mesh,
            }
        end
        if data.meshskin then
            status_addtask {
                type = "resource",
                filename = data.meshskin,
            }
        end
        if data.skeleton then
            status_addtask {
                type = "resource",
                filename = data.skeleton,
            }
        end
        ::continue::
    end
end

function handler.texture(f)
    assetmgr.load_texture(f)
end

function handler.material(f)
    local m = assetmgr.load_material(f)
    assetmgr.unload_material(m)
end

function handler.resource(f)
    touch_res(assetmgr.resource(f))
end

function handler.file(f)
    vfs.realpath(f)
end

local Extension <const> = {
    [".prefab"] = "prefab",
    [".texture"] = "texture",
    [".material"] = "material",
    [".lua"] = "file",
    [".ecs"] = "file",
    [".rcss"] = "file",
    [".rml"] = "file",
    [".efk"] = "file",
    [".ttf"] = "file",
    [".patch"] = "file", --TODO: remove it
}

local Resource <const> = {
    [".texture"] = "texture",
    [".material"] = "material",
    [".glb"] = "",
}

function handler.dir(f)
    for file in fs.pairs(fs.path(f)) do
        local ext = file:extension():string()
        if fs.is_directory(file) then
            if Resource[ext] then
                if Resource[ext] ~= "" then
                    status_addtask {
                        type = Resource[ext],
                        filename = file:string(),
                    }
                end
            else
                status_addtask {
                    type = "dir",
                    filename = file:string(),
                }
            end
        else
            if Extension[ext] then
                status_addtask {
                    type = Extension[ext],
                    filename = file:string(),
                }
            end
        end
    end
end

local function dotask(task)
    log.info(("resources_loader|load %s"):format(task.filename))
    handler[task.type](task.filename)
end

local function worker(index)
    while not status_finish() do
        local task = table.remove(status.pending)
        if not task then
            ltask.sleep(1)
            goto continue
        end
        status.loading = status.loading + 1
        status[index] = task.filename
        dotask(task)
        status.loaded = status.loaded + 1
        status.loading = status.loading - 1
        status[index] = " "
        ::continue::
    end
    status[index] = ""
end

function M:create()
    status = {
        pending = {},
        loading = 0,
        loaded = 0,
        stop = false,
    }

    status_addtask {
        type = "dir",
        filename = "/",
    }
    status_addtask {
        type = "file",
        filename = "/settings",
    }
    status_addtask {
        type = "file",
        filename = "/graphic_settings",
    }
    status_addtask {
        type = "file",
        filename = "/pkg/ant.settings/default/graphic_settings",
    }
    status_addtask {
        type = "file",
        filename = "/pkg/ant.settings/default/settings",
    }

    for i = 1, WorkerNum do
        status[i] = ""
        ltask.fork(worker, i)
    end
    return {
        status = status,
        progress = "0%",
    }
end

function M:stage_camera_usage(datamodel)
    if status_stopped() then
        iui.close("ui/loading.rml")
        return
    end
    for i, v in ipairs(status) do
        datamodel.status[i] = v
    end
    datamodel.loaded = status.loaded
    datamodel.total = status.loading + #status.pending + status.loaded
end

function M:close()
    status.stop = true
    while not status_stopped() do
        ltask.sleep(1)
    end
end

return M
