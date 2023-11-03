local ecs = ...

local iui = ecs.require "engine.system.ui_system"
local assetmgr = import_package "ant.asset"
local vfs = require "vfs"
local ltask = require "ltask"
local fs = require "filesystem"

local M = {}
local WorkerNum <const> = 6
local status

local function status_addtask(task)
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

local Resource <const> = {
    [".texture"] = true,
    [".material"] = true,
    [".glb"] = true,
}

local handler = {}

function handler.file(f)
    vfs.realpath(f)
end
function handler.dir(f)
    for file, file_status in fs.pairs(fs.path(f)) do
        if file_status:is_directory() then
            status_addtask {
                type = "dir",
                filename = file:string(),
            }
        else
            status_addtask {
                type = "file",
                filename = file:string(),
            }
        end
    end
end

local function dotask(task)
    log.info(("resources_loader|load %s"):format(task.filename))
    handler[task.type](task.filename)
end

local function worker(index)
    while not status_finish() do
        local task = table.remove(status.pending, 1)
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

function M.create()
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

    for i = 1, WorkerNum do
        status[i] = ""
        ltask.fork(worker, i)
    end
    return {
        status = status,
        progress = "0%",
    }
end

function M.update(datamodel)
    if status_stopped() then
        iui.close("/pkg/vaststars.resources/ui/loading.rml")
        return
    end
    for i, v in ipairs(status) do
        datamodel.status[i] = v
    end
    datamodel.loaded = status.loaded
    datamodel.total = status.loading + #status.pending + status.loaded
end

function M.close()
    status.stop = true
    while not status_stopped() do
        ltask.sleep(1)
    end
end

return M
