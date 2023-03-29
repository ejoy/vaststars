local fs = require "filesystem"
local serialize = import_package "ant.serialize"
local cr = import_package "ant.compile_resource"

local function parse(fullpath)
    local res = serialize.parse(fullpath, cr.read_file(fullpath))
    local patch = fullpath .. ".patch"
    -- duplicated code - ant.ecs/main.lua -> create_template()
    if fs.exists(fs.path(patch)) then
        local count = #res
        for index, value in ipairs(serialize.parse(patch, cr.read_file(patch))) do
            if value.mount then
                if value.mount ~= 1 then
                    value.mount = count + index - 1
                end
            else
                value.mount = 1
            end
            res[#res + 1] = value
        end
    end
    return res
end

local meshbin ; do
    local meshbin_caches = {}
    function meshbin(fullpath)
        if not meshbin_caches[fullpath] then
            local res = {}
            for _, v in ipairs(parse(fullpath)) do
                if v.data.mesh then
                    res[#res+1] = v.data.mesh
                end
            end
            meshbin_caches[fullpath] = res
        end
        return meshbin_caches[fullpath]
    end
end

return {
    parse = parse,
    meshbin = meshbin,
}