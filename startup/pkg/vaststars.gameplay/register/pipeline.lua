local status = require "status"

return function (name)
    local v = {}
    status.pipelines[name] = v
    local object = {}
    local mt = {}
    setmetatable(object, mt)
    function mt:__index()
        return object
    end
    function mt:__call(stage)
        v[#v+1] = stage
        return object
    end
    return object
end
