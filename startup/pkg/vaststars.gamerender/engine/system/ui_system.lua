local ecs = ...
local world = ecs.world
local w = world.w

local irmlui = ecs.require "ant.rmlui|rmlui_system"
local tracedoc = require "utility.tracedoc"
local table_unpack = table.unpack
local fs = require "filesystem"

local ui_message_mb = world:sub {"ui_message"}

local windowBindings = {} -- = {[url] = { w = xx, datamodel = xx, }, ...}
local changedWindows = {}
local windowListeners = {}
local closeWindows = {}
local leaveWindows = {}
local stage_camera_usage = {}

local guide_progress = 0

local _load_datamodel ; do
    local datamodel_funcs = {}
    local DATAMODEL_PATH <const> = fs.path("/pkg/vaststars.gamerender/ui_datamodel/")

    local function _create_ui_mailbox(url)
        local ui_mailbox = {}
        function ui_mailbox:sub(message)
            return world:sub {"rmlui_message_pub", url, table_unpack(message)}
        end
        return ui_mailbox
    end

    function _load_datamodel(url, datamodel)
        if datamodel_funcs[datamodel] then
            return datamodel_funcs[datamodel]
        end

        local f = DATAMODEL_PATH / datamodel
        if not fs.exists(f) then
            return
        end

        local func, err = loadfile(f:string())
        if not func then
            error(([[Failed to load datamodel %s: %s]]):format(datamodel, err))
        end

        datamodel_funcs[datamodel] = func(ecs, _create_ui_mailbox(url))
        return datamodel_funcs[datamodel]
    end
end

-- uiData = {url, datamodel}
local function open(uiData, ...)
    assert(type(uiData[1]) == "string")
    local url = uiData[1]
    closeWindows[url] = nil
    local datamodel = uiData[2] or url:gsub("^.*/(.*)%.rml$", "%1.lua")

    local binding = windowBindings[url]
    if binding then
        if binding.template then
            binding.param = {...}
            for k, v in pairs(tracedoc.new(binding.template.create(...))) do -- trigger tracedoc.doc_changed
                binding.datamodel[k] = v
            end
            binding.datamodel.guide_progress = guide_progress
            changedWindows[url] = true
        end
        return binding.datamodel
    end

    binding = {}
    binding.window = irmlui.open(url)
    binding.window.addEventListener("message", function(event)
        local res = assert(event.data)
        if res.event == "__CLOSE" then
            local close_url = res.ud[1] or url
            closeWindows[close_url] = true
        elseif res.event == "__PUB" then
            world:pub {"rmlui_message_pub", url, table_unpack(res.ud)}
        else
            assert(false, "Unknown event: " .. res.event)
        end
    end)
    windowBindings[url] = binding

    binding.template = _load_datamodel(url, datamodel)
    if not binding.template then
        return binding.datamodel
    end

    function binding.template.flush()
        changedWindows[url] = nil

        if not tracedoc.changed(binding.datamodel) then
            return
        end

        local ud = {}
        ud.event = "__DATAMODEL"
        ud.ud = tracedoc.diff(binding.datamodel)
        binding.window.postMessage(ud)

        tracedoc.commit(binding.datamodel)
        if windowListeners[url] then
            windowListeners[url](binding.datamodel)
        end
    end

    binding.param = {...}
    binding.datamodel = tracedoc.new(binding.template.create(...))
    binding.datamodel.guide_progress = guide_progress
    binding.template.flush()

    if binding.template.stage_camera_usage then
        stage_camera_usage[url] = true
    end

    return binding.datamodel
end

local function close(url)
    closeWindows[url] = true
end

local ui_system = ecs.system "ui_system"
function ui_system.ui_update()
    for url in pairs(stage_camera_usage) do
        if not closeWindows[url] then
            local binding = windowBindings[url]
            binding.template.stage_camera_usage(binding.datamodel, table_unpack(binding.param))
            if tracedoc.changed(binding.datamodel) then
                changedWindows[url] = true
            end
        end
    end

    -- "close" will clean up windowBindings, so it must be placed at the end of the processing
    for url in pairs(closeWindows) do
        local binding = windowBindings[url]
        if binding then
            if binding.template and binding.template.close then
                binding.template.close(binding.datamodel)
            end
            binding.window:close()
            windowBindings[url] = nil
            changedWindows[url] = nil
            stage_camera_usage[url] = nil
        end
    end
    closeWindows = {}

    -- world to rmlui
    for msg in ui_message_mb:each() do
        for _, binding in pairs(windowBindings) do
            local ud = {}
            ud.event = msg[2]
            ud.ud = {table_unpack(msg, 3, #msg)}
            binding.window.postMessage(ud)
        end
    end

    for url in pairs(changedWindows) do
        if not closeWindows[url] then
            local binding = windowBindings[url]
            if binding then
                binding.template.flush()
            end
        end
    end
end

function ui_system.exit()
    for _, binding in pairs(windowBindings) do
        if binding.template and binding.template.close then
            binding.template.close(binding.datamodel)
        end
    end
end

local iui = {}

function iui.open(...)
    return open(...)
end

function iui.get_datamodel(url)
    local binding = windowBindings[url]
    if not binding then
        return
    end
    return binding.datamodel
end

function iui.close(url)
    close(url)
end

function iui.is_open(url)
    return windowBindings[url] ~= nil
end

function iui.send(url, event, ...)
    local binding = windowBindings[url]
    if binding then
        local ud = {}
        ud.event = event
        ud.ud = {...}
        binding.window.postMessage(ud)
    end
end

function iui.call_datamodel_method(url, event, ...)
    local binding = windowBindings[url]
    if not binding then
        return
    end

    local func = binding.template[event]
    if not func then
        log.error(("can not found event `%s`"):format(event))
        return
    end

    func(binding.datamodel, ...)
    if tracedoc.changed(binding.datamodel) then
        changedWindows[url] = true
    end
end

function iui.set_guide_progress(progress)
    guide_progress = progress
    for url, binding in pairs(windowBindings) do
        if binding.datamodel then -- not all ui has datamodel
            binding.datamodel.guide_progress = progress
            changedWindows[url] = true
        end
    end
end

function iui.redirect(url, ...)
    if windowBindings[url] then
        world:pub {"rmlui_message_pub", url, ...}
    end
end

function iui.broadcast(...)
    for url in pairs(windowBindings) do
        world:pub {"rmlui_message_pub", url, ...}
    end
end

function iui.register_leave(url)
    leaveWindows[url] = true
end

function iui.leave()
    for url in pairs(windowBindings) do
        if leaveWindows[url] then
            iui.close(url)
        end
    end
end

-- for debuger
function iui.add_datamodel_listener(url, func)
    windowListeners[url] = func
end

return iui
