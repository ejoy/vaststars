local tracedoc = require "tracedoc"

local M = {}

function M.pub(window, msg)
    local ud = {}
    ud.event = "__PUB"
    ud.ud = msg
    window.sendMessage(window.getName(), ud)
end

function M.close(window)
    local ud = {}
    ud.event = "__CLOSE"
    ud.ud = {}
    window.sendMessage(window.getName(), ud)
end

function M.onMessage(window, event_funcs)
    window.onMessage(window.getName().."-message", function(data)
        local func = event_funcs[data.event]
        if not func then
            return
        end
        func(table.unpack(data.ud))
    end)
end

function M.createDataMode(window, init)
    local doc = tracedoc.new(init)
    local datamodel = window.createModel(init)
    datamodel.mapping = nil

    window.onMessage(window.getName().."-data-model", function(data)
        if data.event ~= "__DATAMODEL" then
            return
        end

        local diff = data.ud
        if not diff then
            return
        end

        tracedoc.patch(doc, diff)
        tracedoc.patch(datamodel, diff)

        if diff.doc then
            for k in pairs(diff.doc) do
                datamodel(k)
            end
        end

        if datamodel.mapping then
            tracedoc.mapchange(doc, datamodel.mapping)
        end
        tracedoc.commit(doc)
    end)

    return datamodel
end

function M.mapping(datamodel, changeset)
    datamodel.mapping = tracedoc.changeset(changeset or {})
end

return M