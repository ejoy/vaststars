local serialize = import_package "ant.serialize"
local mathpkg = import_package "ant.math"
local aio = import_package "ant.io"
local mc = mathpkg.constant

local parse ; do
    local caches = {}
    function parse(fullpath)
        if not caches[fullpath] then
            caches[fullpath] = serialize.parse(fullpath, aio.readall(fullpath))
        end
        return caches[fullpath]
    end
end

local function slots(fullpath)
    local res = {}
    local t = parse(fullpath)
    for _, v in ipairs(t) do
        if v.data and v.data.slot then
            v.data.scene.s = v.data.scene.s or mc.ONE
            v.data.scene.r = v.data.scene.r or mc.IDENTITY_QUAT
            v.data.scene.t = v.data.scene.t or mc.ZERO_PT

            local name = assert(v.tag[1])
            res[name] = v.data
        end
    end
    return res
end

local function root(fullpath)
    local t = parse(fullpath)
    assert(#t >= 1)
    return t[1]
end

return {
    parse = parse,
    slots = slots,
    root = root,
}