local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local assetmgr = import_package "ant.asset"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local fs = require "filesystem"
local cr = import_package "ant.compile_resource"

local M = {}

function M.init()
    local length
    length = #imaterial.load_res('/pkg/ant.resources/materials/pickup_opacity.material')
    length = #imaterial.load_res('/pkg/ant.resources/materials/pickup_opacity.material', {skinning="GPU"})
    length = #imaterial.load_res('/pkg/ant.resources/materials/pickup_transparent.material')
    length = #imaterial.load_res('/pkg/ant.resources/materials/pickup_transparent.material', {skinning="GPU"})
    length = #imaterial.load_res("/pkg/ant.resources/materials/predepth.material", {depth_type="inv_z"})
    length = #imaterial.load_res("/pkg/ant.resources/materials/predepth.material", {depth_type="inv_z", skinning="GPU"})
    length = #imaterial.load_res("/pkg/ant.resources/materials/singlecolor.material")
    length = #imaterial.load_res("/pkg/ant.resources/materials/canvas_texture.material")

    length = #assetmgr.load_fx {
        fs = "/pkg/ant.resources/shaders/pbr/fs_pbr.sc",
        vs = "/pkg/ant.resources/shaders/pbr/vs_pbr.sc",
        setting = {}
    }
end

function M.load(filename)
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
        ["png"] = function (f)
            length = #assetmgr.resource(f)
        end,
        ["material"] = function (f)
            length = #imaterial.load_res(f)
        end
    }

    local package, fp = filename:match("^%/packages%/(.-)%/(.*)$")
    local package_path = {
        ["gameplay"] = "/pkg/vaststars.gameplay/%s",
        ["gamerender"] = "/pkg/vaststars.gamerender/%s",
        ["resources"] = "/pkg/vaststars.resources/%s",
        ["prototype"] = "/pkg/vaststars.prototype/%s",
    }
    assert(package_path[package], ("package (%s) not found"):format(package))

    local f = (package_path[package]):format(fp)
    local ext = f:match(".*%.(.*)$")

    if not handler[ext] then
        local f <close> = assert(fs.open(fs.path(f), "r"))
        return
    end
    handler[ext](f)
    return true
end

return M