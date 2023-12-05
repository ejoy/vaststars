local tracedoc = require "lua.tracedoc"

local M = {}

function M.pub(msg)
    local ud = {}
    ud.event = "__PUB"
    ud.ud = msg
    window.extern.postMessage(ud)
end

function M.close(url)
    local ud = {}
    ud.event = "__CLOSE"
    ud.ud = {url}
    window.extern.postMessage(ud)
end

function M.addEventListener(event_funcs)
    window.addEventListener("message", function(event)
        if not event.data then
            print("event data is nil")
            return
        end
        local res = event.data
        local func = event_funcs[res.event]
        if not func then
            return
        end
        func(table.unpack(res.ud))
        return
    end)
end

function M.createDataMode(init, onload)
    local doc = tracedoc.new(init)
    local datamodel = window.createModel(init)
    datamodel.mapping = nil
    datamodel.__first = true

    window.addEventListener("message", function(event)
        if not event.data then
            print("event data is nil")
            return
        end
        local res = event.data
        if res.event ~= "__DATAMODEL" then
            return
        end

        local diff = res.ud
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

        if datamodel.__first then
            datamodel.__first = false
            if onload then
                print("onload")
                onload(datamodel)
            end
        end
    end)

    return datamodel
end

function M.mapping(datamodel, changeset)
    datamodel.mapping = tracedoc.changeset(changeset or {})
end

return M