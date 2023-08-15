return function (filename)
    local components = {}
    local types = {}
    local def = {}
    function def.component(name)
        return function (object)
            local fields = { name = name }
            for _, field in ipairs(object) do
                local typename, name, n = field:match "^(.+)%s+([%w_]+)%[(%d+)%]$"
                if name == nil then
                    typename, name = field:match "^(.+)%s+([%w_]+)$"
                end
                fields[#fields+1] = {
                    typename = typename,
                    name = name,
                    n = n,
                }
            end
            components[#components+1] = fields
            types[name] = fields
        end
    end
    function def.type(name)
        return function (object)
            types[name] = object
        end
    end
    assert(loadfile(filename, "t", {}))(def)
    return components, types
end
