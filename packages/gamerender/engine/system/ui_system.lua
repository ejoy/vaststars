local ecs = ...
local world = ecs.world

local irmlui = ecs.import.interface "ant.rmlui|irmlui"
local json = require "engine.system.json"
local tracedoc = require "utility.tracedoc"
local table_unpack = table.unpack
local fs = require "filesystem"

local datamodel_funcs = {}
local rmlui_message_mb = world:sub {"rmlui_message"}
local rmlui_message_close_mb = world:sub {"rmlui_message_close"}
local ui_message_mb = world:sub {"ui_message"}
local window_bindings = {} -- = {[url] = { w = xx, datamodel = xx, }, ...}
local datamodel_changed = {}
local stage_ui_update = {}
local stage_camera_usage = {}
local datamodel_listener = {}

local function create_ui_mailbox(url)
    local ui_mailbox = {}
    function ui_mailbox:sub(message)
        return world:sub {"rmlui_message_pub", url, table_unpack(message)}
    end
    return ui_mailbox
end

local function open(url, ...)
    assert(type(url) == "string")

    local binding = window_bindings[url]
    if binding then
        if binding.template then
            binding.param = {...}
            binding.datamodel = tracedoc.new(binding.template:create(...))
            binding.template:flush()
            datamodel_changed[url] = true
        end
        return binding.window
    end

    binding = {}
    binding.window = irmlui.open(url)
    binding.window.addEventListener("message", function(event)
        if not event.data then
            console.log("event data is null")
            return
        end

        local res, err = json:decode(event.data)
        if not res then
            error(("%s"):format(err))
            return
        end

        if res.event == "__CLOSE" then
            local close_url = res.ud[1] or url
            world:pub {"rmlui_message_close", close_url}
        elseif res.event == "__OPEN" then
            world:pub {"rmlui_message", res.event, table_unpack(res.ud)}
        elseif res.event == "__PUB" then
            world:pub {"rmlui_message_pub", url, table_unpack(res.ud)}
        else
            world:pub {"rmlui_message", res.event, res.ud}
        end
    end)
    window_bindings[url] = binding

    local func = datamodel_funcs[url]
    if not func then
        return binding.window
    end

    binding.template = func(ecs, create_ui_mailbox(url))
    if not binding.template then
        return binding.window
    end

    function binding.template:flush()
        datamodel_changed[url] = nil

        if not tracedoc.changed(binding.datamodel) then
            return
        end

        local ud = {}
        ud.event = "__DATAMODEL"
        ud.ud = tracedoc.diff(binding.datamodel)
        binding.window.postMessage(json:encode(ud))

        tracedoc.commit(binding.datamodel)
        if datamodel_listener[url] then
            datamodel_listener[url](binding.datamodel)
        end
    end

    binding.param = {...}
    binding.datamodel = tracedoc.new(binding.template:create(...))
    if binding.template.onload then
        binding.template.onload(...)
    end
    binding.template:flush()

    if binding.template.stage_ui_update then
        stage_ui_update[url] = true
    end

    if binding.template.stage_camera_usage then
        stage_camera_usage[url] = true
    end

    return binding.window
end

local function world_pub(msg)
    world:pub(msg)
end

local function close(url)
    local binding = window_bindings[url]
    if not binding then
        log.warn(("can not found window `%s`"):format(url))
        return
    end
    binding.window:close()
    window_bindings[url] = nil
    datamodel_changed[url] = nil
    stage_ui_update[url] = nil
    stage_camera_usage[url] = nil
end

local ui_events = {
    __OPEN = open,
    __WORLD_PUB = world_pub,
}

local ui_system = ecs.system "ui_system"
function ui_system.ui_update()
    local event, func

    -- rmlui to world
    for msg in rmlui_message_mb:each() do
        event = msg[2]
        func = assert(ui_events[event], ("Can not found event `%s`"):format(event))
        func(table_unpack(msg, 3, #msg))
    end

    -- world to rmlui
    for msg in ui_message_mb:each() do
        for _, binding in pairs(window_bindings) do
            local ud = {}
            ud.event = msg[2]
            ud.ud = {table_unpack(msg, 3, #msg)}
            binding.window.postMessage(json:encode(ud))
        end
    end

    for url in pairs(stage_ui_update) do
        local binding = window_bindings[url]
        binding.template:stage_ui_update(binding.datamodel, table_unpack(binding.param))
        if tracedoc.changed(binding.datamodel) then
            datamodel_changed[url] = true
        end
    end

    for url in pairs(datamodel_changed) do
        local binding = window_bindings[url]
        if binding then
            binding.template:flush()
        end
    end
end

function ui_system.camera_usage()
    for url in pairs(stage_camera_usage) do
        local binding = window_bindings[url]
        binding.template:stage_camera_usage(binding.datamodel, table_unpack(binding.param))
        if tracedoc.changed(binding.datamodel) then
            datamodel_changed[url] = true
        end
    end

    -- close 会清理 window_bindings, 必须放至最后处理
    -- 放在 camera_usage 处理因为 camera_usage 在 ui_update 后面
    for _, url in rmlui_message_close_mb:unpack() do
        close(url)
    end
end

local iui = ecs.interface "iui"
function iui.open(url, ...)
    return open(url, ...)
end

function iui.close(url)
    close(url)
end

function iui.update(url, event, ...)
    local binding = window_bindings[url]
    if not binding then
        return
    end

    local func = binding.template[event]
    if not func then
        log.error(("can not found event `%s`"):format(event))
        return
    end

    func(binding.template, binding.datamodel, ...)
    if tracedoc.changed(binding.datamodel) then
        datamodel_changed[url] = true
    end
end

function iui.preload_datamodel_dir(dir)
    for file in fs.pairs(fs.path(dir)) do
        if not fs.is_directory(file) then
            local f = file:string()
            local s = file:stem():string()
            local func, err = loadfile(f)
            if not func then
                error(("error loading file '%s':\n\t%s"):format(f, err))
            end
            datamodel_funcs[s .. ".rml"] = func
        end
    end
end

-- for debuger
function iui.add_datamodel_listener(url, func)
    datamodel_listener[url] = func
end