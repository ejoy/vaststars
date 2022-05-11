local ecs = ...
local world = ecs.world

local irmlui = ecs.import.interface "ant.rmlui|irmlui"
local json = import_package "ant.json"
local json_encode = json.encode
local json_decode = json.decode
local syncobj = require "utility.syncobj"

local rmlui_message_mb = world:sub {"rmlui_message"}
local rmlui_message_close_mb = world:sub {"rmlui_message_close"}
local ui_message_mb = world:sub {"ui_message"}
local create_template = ecs.require "ui_datamodel.init"
local window_bindings = {} -- = {[url] = { w = xx, datamodel = xx, }, ...}
local datamodel_changed = {}

local function open(url, ...)
    assert(type(url) == "string")

    local binding = window_bindings[url]
    if binding then
        datamodel_changed[url] = true
        return
    end

    binding = {}
    binding.window = irmlui.open(url)
    binding.window.addEventListener("message", function(event)
        if not event.data then
            console.log("event data is null")
            return
        end

        local res, err = json_decode(event.data)
        if not res then
            error(("%s"):format(err))
            return
        end

        if res.event == "__CLOSE" then
            world:pub {"rmlui_message_close", url}
        elseif res.event == "__OPEN" then
            world:pub {"rmlui_message", res.event, table.unpack(res.ud)}
        else
            world:pub {"rmlui_message", res.event, res.ud}
        end
    end)

    local template = create_template(url)
    if not template then
        return
    end

    binding.template = template
    binding.param = {...}
    binding.source = syncobj.source()
    binding.datamodel = binding.source:new(template.create(...))

    local ud = {}
    ud.event = "__DATAMODEL"
    ud.ud = binding.source:diff(binding.datamodel)
    binding.window.postMessage(json_encode(ud))
    window_bindings[url] = binding
end

local function pub(msg)
    world:pub(msg)
end

local function close(url)
    local w = window_bindings[url]
    if not w then
        return
    end
    w:close()
    window_bindings[url] = nil
end

local ui_events = {
    __OPEN = open,
    __PUB = pub,
    -- __CLOSE = close,
}

local ui_system = ecs.system 'ui_system'
function ui_system.ui_update()
    local event, func

    for _, url in rmlui_message_close_mb:unpack() do
        local binding = window_bindings[url]
        if not binding then
            log.warn(("can not found window `%s`"):format(url))
        else
            binding.window:close()
            window_bindings[url] = nil
            datamodel_changed[url] = nil
        end
    end

    -- rmlui to world
    for msg in rmlui_message_mb:each() do
        event = msg[2]
        func = assert(ui_events[event], ("Can not found event `%s`"):format(event))
        func(table.unpack(msg, 3, #msg))
    end

    -- world to rmlui
    for msg in ui_message_mb:each() do
        for _, binding in pairs(window_bindings) do
            local ud = {}
            ud.event = msg[2]
            ud.ud = {table.unpack(msg, 3, #msg)}
            binding.window.postMessage(json_encode(ud))
        end
    end

    for url, binding in pairs(window_bindings) do
        if binding.template.tick then
            if binding.template.tick(binding.datamodel, binding.param) then
                datamodel_changed[url] = true
            end
        end
    end

    for url in pairs(datamodel_changed) do
        local binding = window_bindings[url]
        if binding then
            local datamodel = binding.datamodel
            local source = binding.source
            local window = binding.window

            local ud = {}
            ud.event = "__DATAMODEL"
            ud.ud = source:diff(datamodel)
            window.postMessage(json_encode(ud))
        end
    end
    datamodel_changed = {}
end

local iui = ecs.interface "iui"
function iui.open(url, ...)
    world:pub {"rmlui_message", "__OPEN", url, ...}
end

function iui.close(url)
    world:pub {"rmlui_message", "__CLOSE", url}
end

function iui.set_datamodel(url, k, v)
    local binding = window_bindings[url]
    if not binding then
        return
    end

    datamodel_changed[url] = true
    binding.datamodel[k] = v
end

function iui.update_datamodel(url, ...)
    local binding = window_bindings[url]
    if not binding then
        return
    end
    local r = binding.template.update(binding.datamodel, binding.param, ...)
    if r then
        datamodel_changed[url] = r
    end
end
