local fs = require "bee.filesystem"
local iatlas = import_package "ant.atlas"

local function getRelativePath(parent_dir, path)
    return "/" .. fs.relative(fs.path(path), parent_dir):string()
end

local function collectRects(parent_dir, image_dir, rects)
    for p in fs.pairs(image_dir) do
        if fs.is_directory(p) then
            collectRects(parent_dir, p, rects)
        else
            local irpath = p:string()
            local ivpath = getRelativePath(parent_dir, irpath)
            local arpath = fs.path(string.gsub(irpath, "images", "textures")):replace_extension("atlas")
            if not fs.exists(arpath:parent_path()) then
                fs.create_directories(arpath:parent_path())
            end
            local avpath = getRelativePath(parent_dir, arpath)
            rects[#rects+1] = {
                irpath = irpath, ivpath = ivpath, arpath = arpath:string(), avpath = avpath
            }
        end
    end
end

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

assert(params.name,             "need texture_name")
assert(params.edge,             "need edge")
assert(params.image_dir,        "need image_dir")
assert(params.parent_dir,       "need parent_dir")
assert(params.atlas_file,       "need atlas_file")

local atlas_file                = string.format("%s/%s.png", params.atlas_file, params.name)
local relative_atlas_file       = getRelativePath(params.parent_dir, atlas_file)
local atlas_texture             = fs.path(string.gsub(atlas_file, "images", "textures")):replace_extension("texture"):string()
local relative_atlas_texture    = getRelativePath(params.parent_dir, atlas_texture)
local rects = {}

if not fs.exists(fs.path(atlas_file):parent_path()) then
    fs.create_directories(fs.path(atlas_file):parent_path())
end

if not fs.exists(fs.path(atlas_texture):parent_path()) then
    fs.create_directories(fs.path(atlas_texture):parent_path())
end

collectRects(params.parent_dir, params.image_dir, rects)

if params.clear == "true" then
    for _, rect in ipairs(rects) do
        fs.remove(rect.arpath)
    end
    fs.remove(atlas_file)
    fs.remove(atlas_texture)
    print("---------------------------------------------------------------------------------------------------------")
    print("Clear Success!")
    print("---------------------------------------------------------------------------------------------------------")
else

    local atlas = {
        name = params.name, x = 1, y = 1, w = tonumber(params.edge), h = tonumber(params.edge), bottom_y = 1,
        rects = rects, irpath = atlas_file, ivpath = relative_atlas_file, trpath = atlas_texture, tvpath = relative_atlas_texture
    }
    
    iatlas.set_atlas(atlas)
    local done = true
    for _, rect in ipairs(atlas.rects) do
        if not rect.was_packed then
            print(rect.name)
            done = false
        end
    end
    if done then
        print("---------------------------------------------------------------------------------------------------------")
        print("Make Success!")
        print("---------------------------------------------------------------------------------------------------------")
    else
        print("---------------------------------------------------------------------------------------------------------")
        print("Make Fail!")
        print("---------------------------------------------------------------------------------------------------------")
    end
end