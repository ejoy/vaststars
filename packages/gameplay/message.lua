local m = {}

local queue = {}

function m.pub(what, ...)
    local q = queue[what]
    if not q then
        q = {}
        queue[what] = q
    end
    q[#q+1] = table.pack(...)
end

local EmptyFunction <const> = function () end

function m.select(what, ...)
    local q = queue[what]
    if not q then
        return EmptyFunction
    end
    queue[what] = nil
    local i = 1
    return function ()
        local v = q[i]
        if v then
            i = i + 1
            return table.unpack(v)
        end
    end
end

return m
