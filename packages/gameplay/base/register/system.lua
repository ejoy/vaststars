local status = require "base.status"

return function (name)
    local v = {}
    status.systems[name] = v
    return v
end
