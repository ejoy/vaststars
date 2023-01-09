local status = require "status"

return function (name)
    name = "vaststars."..name..".system"
    status.csystems[#status.csystems+1] = {name, require(name)}
end
