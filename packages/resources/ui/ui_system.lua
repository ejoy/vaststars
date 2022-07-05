local json = require "json"
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

function M.createDataMode(name, init)
    local doc = tracedoc.new(init)
    local datamodel = window.createModel(name)(init)
    datamodel.mapping = nil

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

        if diff.mod and diff.mod.guide_progress then
            local progress =  diff.mod.guide_progress
            local body = document.getBody()
            local function do_visible(parent, value)
                if not parent.childNodes then
                    return
                end
                for _, child in ipairs(parent.childNodes) do
                    local vv = child.attributes and child.attributes["visible-value"]
                    if vv and tonumber(vv) > value then
                        if child.style then
                            child.style.display = "none"
                        end
                    else
                        if vv and child.style then
                            child.style.display = "flex"
                        end
                        do_visible(child, value)
                    end
                end
            end
            do_visible(body, progress)
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