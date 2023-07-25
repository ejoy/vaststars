local assetmgr = import_package "ant.asset"
local vfs = require "vfs"
local datalist  = require "datalist"

local function touch_res(r)
    local _ = #r
end

local handler = {
    ["prefab"] = function(f)
        local realpath = vfs.realpath(f)
        local lf = assert(io.open(realpath))
        local data = lf:read "a"
        lf:close()
        local prefab_resource = {"material", "mesh", "skeleton", "meshskin", "animation"}
        for _, d in ipairs(datalist.parse(data)) do
            if d.prefab then -- TODO: special case for prefab
                goto continue
            end
            for _, field in ipairs(prefab_resource) do
                if d.data[field] then
                    if field == "material" then
                        local m = assetmgr.load_material(d.data.material)
                        assetmgr.unload_material(m)
                    elseif field == "animation" then
                        for _, v in pairs(d.data.animation) do
                            touch_res(assetmgr.resource(v))
                            vfs.realpath(v:match("^(.+%.).*$") .. "event")
                        end
                    else
                        -- "mesh", "skeleton", "meshskin"
                        touch_res(assetmgr.resource(d.data[field]))
                    end
                end
            end
            ::continue::
        end
    end,
    ["texture"] = function (f)
        assetmgr.load_texture(f)
    end,
    ["material"] = function (f)
        local m = assetmgr.load_material(f)
        assetmgr.unload_material(m)
    end
}

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