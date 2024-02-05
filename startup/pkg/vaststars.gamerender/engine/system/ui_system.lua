local ecs = ...
local world = ecs.world
local w = world.w

local irmlui = ecs.require "ant.rmlui|rmlui_system"
local tracedoc = require "utility.tracedoc"
local table_unpack = table.unpack
local fs = require "filesystem"

local windowBindings = {} -- = {[rml] = { w = xx, datamodel = xx, }, ...}
local changedWindows = {}
local windowListeners = {}
local closeWindows = {}
local leaveWindows = {}
local updateWindows = {}

local guide_progress = 0

local _load_datamodel ; do
    local datamodel_funcs = {}
    local DATAMODEL_PATH <const> = fs.path("/pkg/vaststars.gamerender/ui_datamodel/")

    local function _create_ui_mailbox(rml)
        local ui_mailbox = {}
        function ui_mailbox:sub(message)
            return world:sub {"rmlui_message_pub", rml, table_unpack(message)}
        end
        return ui_mailbox
    end

    function _load_datamodel(rml, datamodel)
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

        datamodel_funcs[datamodel] = func(ecs, _create_ui_mailbox(rml))
        return datamodel_funcs[datamodel]
    end
end

-- v = {rml = xx, datamodel = xx}
local function open(v, ...)
    local rml = v.rml
    local datamodel = v.datamodel or rml:gsub("^.*/(.*)%.html$", "%1.lua")

    closeWindows[rml] = nil

    local binding = windowBindings[rml]
    if binding then
        if binding.template then
            binding.param = {...}
            for k, v in pairs(tracedoc.new(binding.template.create(...))) do -- trigger tracedoc.doc_changed
                binding.datamodel[k] = v
            end
            binding.datamodel.guide_progress = guide_progress
            changedWindows[rml] = true
        end
        return binding.datamodel
    end

    binding = {}

    irmlui.onMessage(rml, function(data)
        local res = assert(data)
        if res.event == "__CLOSE" then
            closeWindows[rml] = true
        elseif res.event == "__PUB" then
            world:pub {"rmlui_message_pub", rml, table_unpack(res.ud)}
        else
            error("Unknown event: " .. res.event)
        end
    end)
    windowBindings[rml] = binding

    binding.template = _load_datamodel(rml, datamodel)
    if not binding.template then
        binding.window = irmlui.open(rml)
        return binding.datamodel
    end

    binding.param = {...}
    binding.datamodel = tracedoc.new(binding.template.create(...))
    tracedoc.commit(binding.datamodel)

    binding.datamodel.guide_progress = guide_progress
    binding.window = irmlui.open(rml, rml, binding.datamodel)

    function binding.template.flush()
        changedWindows[rml] = nil

        if not tracedoc.changed(binding.datamodel) then
            return
        end

        local ud = {}
        ud.event = "__DATAMODEL"
        ud.ud = tracedoc.diff(binding.datamodel)
        irmlui.sendMessage(rml.."-data-model", ud)

        tracedoc.commit(binding.datamodel)
        if windowListeners[rml] then
            windowListeners[rml](binding.datamodel)
        end
    end

    if binding.template.update then
        updateWindows[rml] = true
    end

    return binding.datamodel
end

local function close(rml)
    closeWindows[rml] = true
end

local ui_system = ecs.system "ui_system"
function ui_system.ui_update()
    for rml in pairs(updateWindows) do
        if not closeWindows[rml] then
            local binding = windowBindings[rml]
            binding.template.update(binding.datamodel, table_unpack(binding.param))
            if tracedoc.changed(binding.datamodel) then
                changedWindows[rml] = true
            end
        end
    end

    for rml in pairs(changedWindows) do
        if not closeWindows[rml] then
            local binding = assert(windowBindings[rml])
            binding.template.flush()
        end
    end

    -- "close" will clean up windowBindings, so it must be placed at the end of the processing
    for rml in pairs(closeWindows) do
        local binding = windowBindings[rml]
        if binding then
            if binding.template and binding.template.close then
                binding.template.close(binding.datamodel)
            end
            binding.window:close()
            windowBindings[rml] = nil
            changedWindows[rml] = nil
            updateWindows[rml] = nil
        end
    end
    closeWindows = {}
end

function ui_system.exit()
    for _, binding in pairs(windowBindings) do
        if binding.template and binding.template.close then
            binding.template.close(binding.datamodel)
        end
        binding.window:close()
    end
end

local iui = {}

function iui.open(...)
    return open(...)
end

function iui.get_datamodel(rml)
    local binding = windowBindings[rml]
    if not binding then
        return
    end
    return binding.datamodel
end

function iui.close(rml)
    close(rml)
end

function iui.is_open(rml)
    return windowBindings[rml] ~= nil
end

function iui.send(rml, event, ...)
    local binding = windowBindings[rml]
    if binding then
        local ud = {}
        ud.event = event
        ud.ud = {...}
        irmlui.sendMessage(rml.."-message", ud)
    end
end

function iui.call_datamodel_method(rml, event, ...)
    local binding = windowBindings[rml]
    if not binding then
        return
    end

    local func = binding.template[event]
    if not func then
        log.error(("can not found event `%s`"):format(event))
        return
    end

    changedWindows[rml] = true
    return func(binding.datamodel, ...)
end

function iui.set_guide_progress(progress)
    guide_progress = progress
    for rml, binding in pairs(windowBindings) do
        if binding.datamodel then -- not all ui has datamodel
            binding.datamodel.guide_progress = progress
            changedWindows[rml] = true
        end
    end
end

function iui.redirect(rml, ...)
    if windowBindings[rml] then
        world:pub {"rmlui_message_pub", rml, ...}
    end
end

function iui.broadcast(...)
    for rml in pairs(windowBindings) do
        world:pub {"rmlui_message_pub", rml, ...}
    end
end

function iui.register_leave(rml)
    leaveWindows[rml] = true
end

function iui.leave()
    for rml in pairs(windowBindings) do
        if leaveWindows[rml] then
            close(rml)
        end
    end
end

-- for debuger
function iui.add_datamodel_listener(rml, func)
    windowListeners[rml] = func
end

irmlui.onMessage("reboot", function(...)
    local window = import_package "ant.window"
    local global = require "global"
    global.startup_args = { ... }
    window.reboot {
        feature = { "vaststars.gamerender|gameplay" },
    }
end)

return iui
