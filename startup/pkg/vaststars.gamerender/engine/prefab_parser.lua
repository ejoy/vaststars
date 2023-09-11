local serialize = import_package "ant.serialize"
local assetmgr = import_package "ant.asset"
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant

local function read_file(filename)
    local f
    if string.sub(filename, 1, 1) == "/" then
        f = assert(io.open(assetmgr.compile(filename), "rb"))
    else
        f = assert(io.open(filename, "rb"))
    end
    local c = f:read "a"
    f:close()
    return c
end

local parse ; do
    local caches = {}
    function parse(fullpath)
        if not caches[fullpath] then
            caches[fullpath] = serialize.parse(fullpath, read_file(fullpath))
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

            local name = assert(v.tag:match("^slot|(.+)$"))
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