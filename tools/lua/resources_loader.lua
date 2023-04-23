package.path = "engine/?.lua"
require "bootstrap"

local fs = require "bee.filesystem"
local basedir = (fs.current_path() / "../../"):lexically_normal()
local packagedir = {
    "startup/pkg",
    "3rd/ant/pkg"
}

local function _package_files(root)
    local f <close> = fs.open(fs.path(root) / "package.lua")
    local package_lua = load(f:read "a")()
    local package_name = ("/pkg/%s/"):format(package_lua.name)
    print(package_lua.name)

    local skip_ext = {
        "^.*%.gitignore$",
        "^.*%.git$",
        "^.*%.h$",
        "^.*%.cpp$",
        "^.*%.c$",
        "^.*%.dll$",
        "^.*%.ilk$",
        "^.*%.png$",
        "^.*%.glb$",
        "^.*%.sc$",
        "^.*%.md$",
        "^/pkg/vaststars.prototype/debugger.lua$",
        "^/pkg/ant.bake/.*$",
        "^/pkg/ant.resources.binary/ui/test/.*$",
        "^/pkg/ant.resources.binary/ui/tmp/.*$",
        "^/pkg/ant.resources.binary/test/.*$",
        "^/pkg/ant.resources.binary/textures/water/.*$",
        "^/pkg/ant.resources.binary/textures/effect/num4x4.dds$",
        "^/pkg/ant.resources.binary/textures/yaogandi.dds$",
        "^/pkg/ant.resources.binary/textures/brickwall_normal.dds$",
        "^/pkg/ant.resources.binary/textures/yaogandi.TGA$",
        "^/pkg/ant.resources.binary/textures/pugong_ac.tga$",
        "^/pkg/ant.resources.binary/textures/yaogan.dds$",
        "^/pkg/ant.resources.binary/textures/yaogan.TGA$",
        "^/pkg/ant.resources/materials/billboard/fullscreen_billboard.material$",
        "^/pkg/ant.resources.binary/textures/star/lava_d.dds$",
        "^/pkg/ant.resources/materials/bunny.material$",
        "^/pkg/ant.resources/materials/gamma_test.material$",
        "^/pkg/ant.resources/materials/gizmo_front_line.material$",
        "^/pkg/ant.resources/materials/gizmo_front_singlecolor.material$",
        "^/pkg/ant.resources/materials/ibl/ibl_sample.material$",
        "^/pkg/ant.resources/materials/omni_stencil.material$",
        "^/pkg/ant.resources/materials/postprocess/dof/.*$",
        "^/pkg/ant.resources/materials/skin_model_sample.material$",
        "^/pkg/ant.resources/materials/simpletri.material$",
        "^/pkg/ant.resources/PVPScene/siegeweapon_d.texture$",
        "^/pkg/ant.resources/materials/texture.material$",
        "^/pkg/ant.resources/materials/uvmotion.material$",
        "^/pkg/ant.resources/terrain/terrain.material$",
        "^/pkg/ant.resources/terrain/terrain_mask.material$",
        "^/pkg/ant.resources/terrain/test.material$",
        "^/pkg/ant.resources/textures/default/1x1_gray.texture$",
        "^/pkg/ant.resources/textures/default/1x1_normal.texture$",
        "^/pkg/ant.resources/textures/default_irr.texture$",
        "^/pkg/ant.resources/textures/default_sibl.texture$",
        "^/pkg/ant.resources/textures/pochuan_d.texture$",
        "^/pkg/ant.resources/textures/pochuan_n.texture$",
        "^/pkg/ant.bake/materials/bake_lighting.material$",
        "^/pkg/vaststars.mod.test/.*$",
        ".*mars_pumpjack.*",
    }

    local function _skip_ext(f)
        for _, ext in ipairs(skip_ext) do
            if f:match(ext) then
                return true
            end
        end
        return false
    end

    local function _get_files(p)
        local t = {}
        for v in fs.pairs(fs.path(p)) do
            if fs.is_directory(v) then
                local tmp = _get_files(v)
                table.move(tmp, 1, #tmp, #t + 1, t)
            else
                local f = ("%s%s"):format(package_name, fs.relative(v, root))
                if not _skip_ext(f) then
                    t[#t+1] = f
                end
            end
        end
        return t
    end
    return _get_files(root)
end

local t = {}
for _, v in ipairs(packagedir) do
    for file in fs.pairs(fs.path(basedir / v)) do
        if fs.is_directory(file) then
            local tmp = _package_files( file:lexically_normal() )
            table.move(tmp, 1, #tmp, #t + 1, t)
        end
    end
end
table.sort(t)

local function containsChinese(str)
    if not str then
        return false
    end
    local pattern = "[\226\128\168-\239\191\189]+"
    return string.find(str, pattern) ~= nil
end

local function containsSpace(path)
    return string.match(path, "%s")
end

local err = false
local s = {}
s[#s+1] = "local t = {"
for _, v in ipairs(t) do
    if containsChinese(v) then
        err = true
        log.error("path contains chinese: ", v)
    end
    if containsSpace(v) then
        err = true
        log.error("path contains space: ", v)
    end
    s[#s+1] = ([[%s"%s",]]):format("\t", v)
end

if err then
    error(false)
end

s[#s+1] = ([[%s"/pkg/vaststars.resources/glb/animation/Interact_build.glb|animation.prefab"]]):format("\t")
s[#s+1] = "}"
s[#s+1] = "return t"

print("Output", fs.path(basedir) / "gamerender/resources.lua")
local f <close> = assert(io.open(fs.path(basedir / "startup/pkg/vaststars.gamerender/resources.lua"):string(), "wb"))
f:write(table.concat(s, "\n"))