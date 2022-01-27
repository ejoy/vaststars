local function deep_copy(src, dst)
    dst = dst or {}
    for k, v in pairs(src) do
        local t = type(v)
        if t == "table" then
            dst[k] = {}
            deep_copy(v, dst[k])
        else
            assert(t ~= "function")
            dst[k] = v
        end
    end
    return dst
end
return deep_copy