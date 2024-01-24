local fs = require "bee.filesystem"

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

if params.remove_all then
    print("cleaning textures")
    fs.remove_all(params.textures_dir)
end

local function findAllImagesRecursively(directory, files)
    for p in fs.pairs(directory) do
        if fs.is_directory(p) then
            findAllImagesRecursively(p, files)
        else
            if p:equal_extension ".png" then
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

        local file <close> = assert(io.open(texturePath:string(), 'wb'))
        file:write(TEXTURE_CONTENT:format(relativePath))
    end
end

local images = {}
findAllImagesRecursively(params.images_dir, images)
generateTextures(images, params.images_dir, params.textures_dir)
