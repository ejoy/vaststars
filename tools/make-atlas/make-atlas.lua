package.path = "/engine/?.lua"
require "bootstrap"

local fs = require "bee.filesystem"
local iatlas = import_package "ant.atlas"

local function parseArguments(allargs)
    local args = allargs[1]
    local result = {}
    for _, arg in ipairs(args) do
        local key, value = arg:match("--([%w_]+)=(.*)")
        if key and value then
            result[key] = value
        end
    end
    return result
end

local params = parseArguments({...})

assert(params.texture_dir,  "need texture_dir")
assert(params.name,         "need texture_name")
assert(params.image_dir,    "need image_dir")
assert(params.width,        "need width")
assert(params.height,       "need height")
assert(params.parent_dir,   "need parent_dir")
if params.clear then
    for atlas in fs.pairs(params.texture_dir) do
        if atlas:equal_extension(".atlas") then
            fs.remove(atlas)
        end
    end
    local atlasFilePath = string.format("%s/%s.png", fs.path(params.image_dir):string(), params.name)
    local atlasTexturePath = string.format("%s/%s.texture", fs.path(params.texture_dir):string(), params.name)
    fs.remove(atlasFilePath)
    fs.remove(atlasTexturePath)
    print("Clear Done")
else
    local imageRelativePath = "/" .. fs.relative(fs.path(params.image_dir), params.parent_dir):string()
    local textureRelativePath = "/" .. fs.relative(fs.path(params.texture_dir), params.parent_dir):string()
    
    local atlas = {
        name = params.name, x = 1, y = 1, w = tonumber(params.width), h = tonumber(params.height), bottom_y = 1,
        vpath = imageRelativePath,
        rpath = params.image_dir,
        tvpath = textureRelativePath,
        trpath = params.texture_dir
    }
    
    iatlas.set_atlas(atlas)
    for _, rect in ipairs(atlas.rects) do
        if not rect.was_packed then
            print(rect.name)
        end
    end
    print("Make Done")
end