local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local assetmgr = import_package "ant.asset"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local fs = require "filesystem"

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
    local skip = {"glb", "sc"}
    local handler = {
        ["prefab"] = function(f)
            local fs = require "filesystem"
            local datalist  = require "datalist"
            local lf = assert(fs.open(fs.path(f)))
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
                            length = #imaterial.load_res(d.data.material, d.data.material_setting)
                        elseif field == "animation" then
                            for _, v in pairs(d.data.animation) do
                                length = #assetmgr.resource(v)
                                local f <close> = fs.open(fs.path(v:match("^(.+%.).*$") .. "event"), "r")
                            end
                        else
                            length = #assetmgr.resource(d.data[field])
                        end
                    end
                end
                ::continue::
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

    local ext = filename:match(".*%.(.*)$")
    for _, _ext in ipairs(skip) do
        if ext == _ext then
            return
        end
    end

    log.info(("resources_loader|load %s"):format(filename))
    if not handler[ext] then
        local f <close> = assert(fs.open(fs.path(filename), "r"))
        return
    end
    handler[ext](filename)
    return true
end

return M