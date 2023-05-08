return function (mailbox, events, handler)
    local mbs = {}
    for _, event in ipairs(events) do
        mbs[event] = mailbox:sub({event})
    end
    return function(...)
        for event, mb in pairs(mbs) do
            for _ in mb:unpack() do
                handler(event, ...)
            end
        end
    end
end