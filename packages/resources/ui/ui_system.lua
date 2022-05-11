local json = require "json"
local json_encode = json.encode
local json_decode = json.decode

local m = {}
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

function m:close()
    local ud = {}
    ud.event = "__CLOSE"
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

local function patch(datamodel, diff, func)
    local t = {}
	local n = #diff
	for i = 2, n, 2 do
        assert(diff[i] ~= json.null)

        local k, v = diff[i], diff[i+1]
		datamodel[k] = v
        if type(v) == "table" then
            datamodel(k)
        end

        t[k] = v
	end
	if n % 2 == 0 then
        assert(false) -- 目前不存在删除 key 的情况
		-- remove keys
		for _, v in ipairs(diff[n]) do
			datamodel[v] = nil
		end
	end
    if func then
        func(t)
    end
	return datamodel
end

function m:setDataModel(datamodel, func)
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

        patch(datamodel, res.ud, func)
    end)
end

return m