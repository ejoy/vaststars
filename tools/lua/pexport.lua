package.path = "engine/?.lua;?.lua"
require "bootstrap"

local lfs = require "filesystem.local"
local fs = require "bee.filesystem"
local project_dir = (fs.current_path() / "../../")
local resources_dir = (project_dir / "packages/resources/"):lexically_normal()
local cr = import_package "ant.compile_resource"
cr.init()

local function _get_resources_files(resources_dir, pat, exclude_pat)
    local f <close> = fs.open(fs.path(resources_dir) / "package.lua")
    local package_lua = load(f:read "a")()
    local package_name = ("/pkg/%s/"):format(package_lua.name)

    local function _get_files(p)
        local t = {}
        for v in fs.pairs(fs.path(p)) do
            if fs.is_directory(v) then
                local tmp = _get_files(v)
                table.move(tmp, 1, #tmp, #t + 1, t)
            else
                local f = ("%s%s"):format(package_name, fs.relative(v, resources_dir))
                if f:match(pat) and not f:match(exclude_pat) then
                    t[#t+1] = v
                end
            end
        end
        return t
    end
    return _get_files(resources_dir)
end

local function _table_length(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

local function _get_prefab_related_glb(path)
    local datalist  = require "datalist"
    local lf = assert(lfs.open(fs.path(path)))
    local data = lf:read "a"
    lf:close()

    local t = {}
    for _, v in ipairs(datalist.parse(data)) do
        if not v.data then
            goto continue1
        end
        for k1, v1 in pairs(v.data) do
            if type(v1) ~= "string" then
                goto continue
            end

            local glb = v1:match("(.*%.glb).*$")
            if glb then
                t[glb] = true
            end

            ::continue::
        end

        ::continue1::
    end

    assert(_table_length(t) <= 1)
    return next(t)
end

local t = _get_resources_files(resources_dir, "^.*%.prefab$", "^.*%-animation%.prefab$")
local glb_to_prefab = {}
for _, v in ipairs(t) do
    local glb = _get_prefab_related_glb(v)
    if not glb then
        goto continue
    end

    glb_to_prefab[glb] = glb_to_prefab[glb] or {}
    glb_to_prefab[glb][#glb_to_prefab[glb]+1] = v
    ::continue::
end

local function _save(glb, prefab)
    local data = cr.read_file(glb .. "|mesh.prefab")
    local lf = assert(lfs.open(fs.path(prefab), "wb"))
    data = data:gsub("%$path %.%/", glb .. "|")
    data = data:gsub("%$path \"%./(.-)\n", "\"" .. glb .. "|%1\n") -- material: $path "./materials/材质.004.material"
    lf:write(data)
    lf:close()
end

for glb, prefabs in pairs(glb_to_prefab) do
    if #prefabs ~= 1 then
        print(("skip %s: %d"):format(glb, #prefabs))
        for _, prefab in ipairs(prefabs) do
            --- print(("    %s"):format(prefab))
        end
        goto continue
    end
    -- print(glb, "--->", prefabs)

    _save(glb, prefabs[1])
    ::continue::
end
-- print(prefab_dir)