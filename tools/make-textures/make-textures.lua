package.path = "/engine/?.lua"
require "bootstrap"

local fs = require "bee.filesystem"
local datalist = require "datalist"
local serialize = import_package "ant.serialize"

local function parseArguments(args)
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
assert(params.images_dir, "need images_dir")
assert(params.textures_dir, "need textures_dir")

local function findAllFilesRecursively(directory, extension, files)
    for p in fs.pairs(directory) do
        if fs.is_directory(p) then
            findAllFilesRecursively(p, extension, files)
        else
            if p:equal_extension(extension) then
                files[#files + 1] = p
            end
        end
    end
end

local TEXTURE_CONTENT <const> = [[
colorspace: sRGB
compress:
  android: ASTC6x6
  ios: ASTC6x6
  windows: BC3
noresize: true
normalmap: false
path: %s
sampler:
  MAG: LINEAR
  MIN: LINEAR
  U: WRAP
  V: WRAP
type: texture
]]

local function generateTextures(images, imgDir, texDir)
    for _, image in ipairs(images) do
        local texturePath = fs.path(texDir) / fs.relative(image, fs.path(imgDir)):replace_extension("texture")
        local relativePath = fs.relative(image, texturePath:parent_path()):string()

        if not fs.exists(texturePath:parent_path()) then
            fs.create_directories(texturePath:parent_path())
        end

        if fs.exists(texturePath) then
            local f <close> = assert(io.open(texturePath:string(), 'r'))
            local d = datalist.parse(f:read "a")

            -- special case for lattice
            if d.lattice then
                local l = serialize.stringify({lattice = d.lattice})
                local file <close> = assert(io.open(texturePath:string(), 'wb'))
                file:write(TEXTURE_CONTENT:format(relativePath) .. l)
                goto continue
            end
        end

        local file <close> = assert(io.open(texturePath:string(), 'wb'))
        file:write(TEXTURE_CONTENT:format(relativePath))
        ::continue::
    end
end

local images = {}
local textures = {}
findAllFilesRecursively(params.images_dir, ".png", images)
findAllFilesRecursively(params.textures_dir, ".texture", textures)
generateTextures(images, params.images_dir, params.textures_dir)

if params.clear then
    for _, texture in ipairs(textures) do
        if not fs.exists(params.images_dir / fs.relative(texture, params.textures_dir):replace_extension(".png")) then
            print("Removing " .. texture)
            fs.remove(texture)
        end
    end
end
print("Done")