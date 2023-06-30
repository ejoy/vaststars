-- .\bin\msvc\release\vaststars.exe this.lua %*

local fs = require "bee.filesystem"
local dir = (fs.exe_path() / "../../../../"):lexically_normal():string()
local ui_dir = ...
if not ui_dir then
    ui_dir = fs.path(dir .. [[startup\pkg\vaststars.resources\ui\]])
else
    ui_dir = fs.path(ui_dir)
    print(ui_dir:string())
end

local ui_image_dir = ui_dir / [[image\]]
local ui_texture_dir = ui_dir / [[textures\]]

local function get_files(dir)
    local r = {}
    for v in fs.pairs(dir) do
        if fs.is_directory(v) then
            local t = get_files(v)
            table.move(t, 1, #t, #r + 1, r)
        else
            r[#r+1] = v
        end
    end
    return r
end

local function filter_extension(list, extensions)
    local t = {}
    for _, path in ipairs(list) do
        for _, extension in ipairs(extensions) do
            if path:equal_extension(extension) then
                t[#t+1] = path
            end
        end
    end
    return t
end

local function escape_magic(pattern)
	return (pattern:gsub("%W", "%%%1"))
end

local texture_content <const> = [[
colorspace: sRGB
compress:
    android: ASTC6x6
    ios: ASTC6x6
    windows: BC3
noresize: true
normalmap: false
path: ../../image/%s
sampler:
    MAG: LINEAR
    MIN: LINEAR
    U: WRAP
    V: WRAP
type: texture
]]

local function gen_png_texture(png_list)
    for _, v in ipairs(png_list) do
        local s = ("^%s(.*)$"):format(escape_magic(ui_image_dir:string()))
        local relative_png_file = v:string():match(s)
        local absolute_texture_file = fs.path(ui_texture_dir) / fs.path(relative_png_file):replace_extension(".texture")

        if not fs.exists(absolute_texture_file:parent_path()) then
            fs.create_directories(absolute_texture_file:parent_path())
        end

        local f = assert(io.open(absolute_texture_file:string(), 'wb'))
        f:write(texture_content:format(relative_png_file))
        f:close()
    end
end

local lst = get_files(ui_dir)
local png_list = filter_extension(lst, {".png"})

gen_png_texture(png_list)
