local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local assetmgr = import_package "ant.asset"
local imaterial = ecs.import.interface "ant.asset|imaterial"

local M = {}

function M.init()
    local length
    length = #imaterial.load_res('/pkg/ant.resources/materials/pickup_opacity.material')
    length = #imaterial.load_res('/pkg/ant.resources/materials/pickup_opacity.material', {skinning="GPU"})
    length = #imaterial.load_res('/pkg/ant.resources/materials/pickup_transparent.material')
    length = #imaterial.load_res('/pkg/ant.resources/materials/pickup_transparent.material', {skinning="GPU"})
    length = #imaterial.load_res("/pkg/ant.resources/materials/predepth.material", {depth_type="inv_z"})
    length = #imaterial.load_res("/pkg/ant.resources/materials/predepth.material", {depth_type="inv_z", skinning="GPU"})

    assetmgr.load_fx {
        fs = "/pkg/ant.resources/shaders/pbr/fs_pbr.sc",
        vs = "/pkg/ant.resources/shaders/pbr/vs_pbr.sc",
    }
end

function M.load(filename)
    local skip = {"glb", "cfg", "hdr", "dds", "anim", "event", "lua", "efk", "rml", "rcss", "ttc", "png", "material"}
    local handler = {
        ["prefab"] = function(f)
            local fs = require "filesystem"
            local datalist  = require "datalist"
            local lf = assert(fs.open(fs.path(f)))
            local data = lf:read "a"
            lf:close()
            local prefab_resource = {"material", "mesh", "skeleton", "meshskin"}
            for _, d in ipairs(datalist.parse(data)) do
                for _, field in ipairs(prefab_resource) do
                    if d.data[field] then
                        if field == "material" then
                            length = #imaterial.load_res(d.data.material, d.data.material_setting)
                        else
                            length = #assetmgr.resource(d.data[field])
                        end
                    end
                end
            end
        end,
        ["texture"] = function (f)
            length = #assetmgr.resource(f)
        end,
    }

    local f = ("/pkg/vaststars.resources%s"):format(filename)
    local ext = f:match(".*%.(.*)$")

    for _, _ext in ipairs(skip) do
        if ext == _ext then
            return
        end
    end

    assert(handler[ext], "unknown resource type " .. ext)
    handler[ext](f)
    return true
end

return M