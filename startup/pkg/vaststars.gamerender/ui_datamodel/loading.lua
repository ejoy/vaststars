local ecs = ...

local iui = ecs.import.interface "vaststars.gamerender|iui"
local assetmgr = import_package "ant.asset"
local vfs = require "vfs"
local datalist  = require "datalist"
local ltask = require "ltask"

local M = {}
local WorkerNum <const> = 6
local status

local function status_addtask(task)
    status.pending[#status.pending+1] = task
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
    for _, e in ipairs(datalist.parse(prefab_data)) do
        if e.prefab then -- TODO: special case for prefab
            goto continue
        end
        local data = e.data
        if data.material then
            local m = assetmgr.load_material(data.material)
            assetmgr.unload_material(m)
        end
        if data.animation then
            for _, v in pairs(data.animation) do
                touch_res(assetmgr.resource(v))
                vfs.realpath(v:match("^(.+%.).*$") .. "event")
            end
        end
        if data.mesh then
            touch_res(assetmgr.resource(data.mesh))
        end
        if data.meshskin then
            touch_res(assetmgr.resource(data.meshskin))
        end
        if data.skeleton then
            touch_res(assetmgr.resource(data.skeleton))
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

local function dotask(filename)
    local ext = filename:match(".*%.(.*)$")
    log.info(("resources_loader|load %s"):format(filename))
    if handler[ext] then
        handler[ext](filename)
    else
        vfs.realpath(filename)
    end
end

local function worker(index)
    while not status_finish() do
        local filename = table.remove(status.pending)
        if not filename then
            ltask.sleep(1)
            goto continue
        end
        status.loading = status.loading + 1
        status[index] = filename
        dotask(filename)
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

    for _, v in ipairs(require "resources") do
        status_addtask(v)
    end

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
    local progress = status.loaded / (status.loading + #status.pending + status.loaded)
    datamodel.progress = string.format("%d%%", math.floor(progress * 100))
end

function M:close()
    status.stop = true
    while not status_stopped() do
        ltask.sleep(1)
    end
end

return M
