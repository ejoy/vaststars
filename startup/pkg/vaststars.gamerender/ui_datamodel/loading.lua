local ecs = ...

local iui = ecs.import.interface "vaststars.gamerender|iui"
local assetmgr = import_package "ant.asset"
local vfs = require "vfs"
local ltask = require "ltask"
local fs = require "filesystem"

local M = {}
local WorkerNum <const> = 6
local status

local BlackList <const> = {
    ["/pkg/vaststars.mod.test"] = true,
    ["/pkg/ant.bake"] = true,
    ["/pkg/ant.resources.binary/test"] = true,
    ["/pkg/ant.resources.binary/meshes"] = true,
    ["/pkg/ant.efk/efkbgfx/examples"] = true,
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

local Resource <const> = {
    [".texture"] = true,
    [".material"] = true,
    [".glb"] = true,
}

local File <const> = {
    -- ecs
    [".prefab"] = true,
    [".ecs"] = true,
    -- script
    [".lua"] = true,
    -- ui
    [".bundle"] = true,
    [".rcss"] = true,
    [".rml"] = true,
    -- effect
    [".efk"] = true,
    -- font
    [".ttf"] = true,
    [".otf"] = true, --TODO: remove it?
    [".ttc"] = true, --TODO: remove it?
    -- sound
    [".bank"] = true,
    -- animation
    [".event"] = true,
    [".anim"] = true,
    -- compiled resource
    [".bin"] = true,
    [".cfg"] = true,
    [".ozz"] = true,
    [".vbbin"] = true,
    [".vb2bin"] = true,
    [".ibbin"] = true,
    [".meshbin"] = true,
    [".skinbin"] = true,
    --TODO: remove they
    [".patch"] = true,
    [""] = true,
}

local handler = {}

if __ANT_RUNTIME__ then
    function handler.file(f)
        vfs.realpath(f)
    end
    function handler.dir(f)
        for file in fs.pairs(fs.path(f)) do
            if fs.is_directory(file) then
                status_addtask {
                    type = "dir",
                    filename = file:string(),
                }
            else
                local ext = file:extension():string()
                if File[ext] then
                    status_addtask {
                        type = "file",
                        filename = file:string(),
                    }
                end
            end
        end
    end
else
    function handler.file(f)
    end
    function handler.compile(f)
        assetmgr.compile_file(vfs.realpath(f))
    end
    function handler.dir(f)
        for file in fs.pairs(fs.path(f)) do
            if fs.is_directory(file) then
                local ext = file:extension():string()
                if Resource[ext] then
                    status_addtask {
                        type = "compile",
                        filename = file:string(),
                    }
                else
                    status_addtask {
                        type = "dir",
                        filename = file:string(),
                    }
                end
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
