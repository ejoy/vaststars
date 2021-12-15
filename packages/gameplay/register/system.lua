local status = require "status"

return function (name)
    local v = {}
    status.systems[name] = v
    return v
end
