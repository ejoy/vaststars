local command = ...
package.path = "engine/?.lua"
require "bootstrap"

local lfs = require "filesystem"
local fs = require "bee.filesystem"
local serialize = import_package "ant.serialize".stringify
local datalist = require "datalist"

local dir = (fs.exe_path() / "../../../../"):lexically_normal():string()
local prefab_dir = fs.path(dir .. "startup/pkg/vaststars.resources/prefabs"):localpath()
local prefab_patch_dir = (prefab_dir / "../../../tools/data/prefab-patch"):lexically_normal()

local function get_prefab_files(dir)
    local r = {}
    for file in fs.pairs(fs.path(dir)) do
        if fs.is_directory(file) then
            local t = get_prefab_files(dir / file)
            table.move(t, 1, #t, #r + 1, r)
        else
            r[#r+1] = file:localpath():lexically_normal():string()
        end
    end
    table.sort(r, function(a, b) return a < b end)
    return r
end

local function readfile(filename)
	local f = assert(fs.open(filename))
	local data = f:read "a"
	f:close()
	return data
end

local function writefile(filename, c, mode)
    if not fs.exists(filename:parent_path()) then
        fs.create_directories(filename:parent_path())
    end

    mode = mode or "wb"
    local f<close>, errmsg = fs.open(filename, mode)
    f:write(c)
end

local function escape_magic(pattern)
	return (pattern:gsub("%W", "%%%1"))
end

local function get_relative(file, dir)
    local s = ("^%s(.*)$"):format(escape_magic(dir))
    return file:match(s)
end

local checked = {}
checked[#checked+1] = function(v)
    return v.data.name == "Scene" and next(v.data.scene)
end
checked[#checked+1] = function(v)
    return v.data.slot
end
checked[#checked+1] = function(v)
    return v.data.efk
end

local function save(prefab_dir, prefab_patch_dir)
    if not fs.exists(prefab_patch_dir) then
        fs.create_directories(prefab_patch_dir)
    end

    for _, file in pairs(get_prefab_files(prefab_dir)) do
        local ok, data = pcall(datalist.parse, readfile(fs.path(file)))
        assert(ok, ("failed to read file `%s`"):format(file))

        local relative = get_relative(file, fs.path(prefab_dir):localpath():string())

        local backup_data = {}
        for _, v in ipairs(data) do
            for _, check in ipairs(checked) do
                if v.data and check(v) then
                    backup_data[#backup_data+1] = v
                end
            end
        end

        if next(backup_data) then
            print(relative)
            writefile(fs.path(prefab_patch_dir:string() .. relative), serialize(backup_data))
        end
    end
end

local function sorttable(t, sortfunc)
    local sort = {}
    for _, v in pairs(t) do
        sort[#sort+1] = v
    end
    table.sort(sort, sortfunc)
    return sort
end

local function patch(prefab_dir, prefab_patch_dir)
    if not fs.exists(prefab_patch_dir) then
        log.error(("can not found patch dir `%s`"):format(prefab_patch_dir))
        return
    end

    for _, file in pairs(get_prefab_files(prefab_patch_dir)) do
        local ok, data = pcall(datalist.parse, readfile(fs.path(file)))
        assert(ok, ("failed to read file `%s`"):format(file))

        local cache = {}
        for index, v in ipairs(data) do
            cache[v.data.name] = {index = index, v = v}
        end

        local relative = get_relative(file, fs.path(prefab_patch_dir):localpath():string())
        ok, data = pcall(datalist.parse, readfile(fs.path(prefab_dir:string() .. relative)))
        assert(ok, ("failed to read file `%s`"):format(file))

        local replace = {}
        for index, v in ipairs(data) do
            if v.data and cache[v.data.name] then
                replace[#replace + 1] = {index = index, v = cache[v.data.name].v}
                cache[v.data.name] = nil
            end
        end

        for _, v in pairs(replace) do
            data[v.index] = v.v
        end

        for _, v in ipairs(sorttable(cache, function(a, b) return a.index < b.index end)) do
            data[#data+1] = v.v
        end

        print(relative)
        writefile(fs.path(prefab_dir:string() .. relative), serialize(data))
    end
end

----

if command == "save" then
    print("save patch")
    save(prefab_dir, prefab_patch_dir)
elseif command == "patch" then
    print("apply patch")
    patch(prefab_dir, prefab_patch_dir)
else
    log.error(("unknown command `%s`"):format(command))
end
