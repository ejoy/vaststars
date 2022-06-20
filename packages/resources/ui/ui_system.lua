local json = require "json"
local json_encode = json.encode
local json_decode = json.decode
local tracedoc = require "lua.tracedoc"

local m = {}
function m:world_pub(msg)
    local ud = {}
    ud.event = "__WORLD_PUB"
    ud.ud = msg
    window.extern.postMessage(json_encode(ud))
end

function m:pub(msg)
    local ud = {}
    ud.event = "__PUB"
    ud.ud = msg
    window.extern.postMessage(json_encode(ud))
end

function m:open(url, ...)
    local ud = {}
    ud.event = "__OPEN"
    ud.ud = {url, ...}
    window.extern.postMessage(json_encode(ud))
end

function m:close(url)
    local ud = {}
    ud.event = "__CLOSE"
    ud.ud = {url}
    window.extern.postMessage(json_encode(ud))
end

function m:addEventListener(event_funcs)
    window.addEventListener("message", function(event)
        if not event.data then
            console.log("event data is nil")
            return
        end
        local res, err = json_decode(event.data)
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

function m:createDataMode(name, init)
    local doc = tracedoc.new(init)
    local datamodel = window.createModel(name)(init)
    datamodel.mapping = nil

    window.addEventListener("message", function(event)
        if not event.data then
            console.log("event data is nil")
            return
        end
        local res, err = json_decode(event.data)
        if not res then
            error(('%s'):format(err))
            return
        end

        if res.event ~= "__DATAMODEL" then
            return
        end

        local diff = res.ud
        tracedoc.patch(doc, diff)
        tracedoc.patch(datamodel, diff)

        for k in pairs(diff.doc) do
            datamodel(k)
        end

        if datamodel.mapping then
            tracedoc.mapupdate(doc, datamodel.mapping)
        end
        tracedoc.commit(doc)
    end)

    return datamodel
end

function m:mapping(datamodel, changeset)
    datamodel.mapping = tracedoc.changeset(changeset or {})
end

return m