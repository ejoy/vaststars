local assetmgr = import_package "ant.asset"
local vfs = require "vfs"
local datalist  = require "datalist"

local function touch_res(r)
    local _ = #r
end

local handler = {}

function handler.prefab(f)
    local realpath = vfs.realpath(f)
    local lf = assert(io.open(realpath))
    local prefab_data = lf:read "a"
    lf:close()
    for _, d in ipairs(datalist.parse(prefab_data)) do
        if d.prefab then -- TODO: special case for prefab
            goto continue
        end
        local data = d.data
        if data.material then
            local m = assetmgr.load_material(data.material)
            assetmgr.unload_material(m)
        end
        if data.animation then
            for _, v in pairs(data.animation) do
                touch_res(assetmgr.resource(v))
                vfs.realpath(v:match("^(.+%.).*$") .. "event")
            end
        end
        if data.mesh then
            touch_res(assetmgr.resource(data.mesh))
        end
        if data.meshskin then
            touch_res(assetmgr.resource(data.meshskin))
        end
        if data.skeleton then
            touch_res(assetmgr.resource(data.skeleton))
        end
        ::continue::
    end
end

function handler.texture(f)
    assetmgr.load_texture(f)
end

function handler.material(f)
    local m = assetmgr.load_material(f)
    assetmgr.unload_material(m)
end

local M = {}

function M.load(filename)
    local ext = filename:match(".*%.(.*)$")
    log.info(("resources_loader|load %s"):format(filename))
    if handler[ext] then
        handler[ext](filename)
    else
        vfs.realpath(filename)
    end
end

return M
