local status = require "base.status"

return function (name)
    status.csystems[name] = true
end
