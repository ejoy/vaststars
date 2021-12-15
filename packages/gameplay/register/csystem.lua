local status = require "status"

return function (name)
    name = "vaststars."..name..".system"
    status.csystems[name] = require(name)
end
