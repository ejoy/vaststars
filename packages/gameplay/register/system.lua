local status = require "status"

return function (name)
    local v = {}
    status.systems[#status.systems+1] = {name, v}
    return v
end
