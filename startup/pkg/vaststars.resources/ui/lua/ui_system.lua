local json = require "lua.json"
local tracedoc = require "lua.tracedoc"

local M = {}
function M.world_pub(msg)
    local ud = {}
    ud.event = "__WORLD_PUB"
    ud.ud = msg
    window.extern.postMessage(json:encode(ud))
end

function M.pub(msg)
    local ud = {}
    ud.event = "__PUB"
    ud.ud = msg
    window.extern.postMessage(json:encode(ud))
end

function M.open(url, ...)
    local ud = {}
    ud.event = "__OPEN"
    ud.ud = {url, ...}
    window.extern.postMessage(json:encode(ud))
end

function M.close(url)
    local ud = {}
    ud.event = "__CLOSE"
    ud.ud = {url}
    window.extern.postMessage(json:encode(ud))
end

function M.addEventListener(event_funcs)
    window.addEventListener("message", function(event)
        if not event.data then
            console.log("event data is nil")
            return
        end
        local res, err = json:decode(event.data)
        if res then
            local func = event_funcs[res.event]
            if not func then
                return
            end
            func(table.unpack(res.ud))
            return
        end
        error(('%s'):format(err))
    end)
end

function M.createDataMode(init, onload)
    local doc = tracedoc.new(init)
    local datamodel = window.createModel(init)
    datamodel.mapping = nil
    datamodel.__first = true

    window.addEventListener("message", function(event)
        if not event.data then
            console.log("event data is nil")
            return
        end
        local res, err = json:decode(event.data)
        if not res then
            error(('%s'):format(err))
            return
        end

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
                console.log("onload")
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