local lm = require "luamake"


local plat = (function ()
    if lm.os == "windows" then
        if lm.compiler == "gcc" then
            return "mingw"
        end
        return "msvc"
    end
    return lm.os
end)()

lm.mode = "debug"
lm.builddir = ("build/%s/%s"):format(plat, lm.mode)
lm.bindir = ("bin/%s/%s"):format(plat, lm.mode)

if lm.os == "ios" then
    lm.arch = "arm64"
    if lm.mode == "release" then
        lm.sys = "ios13.0"
    else
        lm.sys = "ios14.1"
    end
end

lm.ios = {
    flags = {
        "-fembed-bitcode",
        "-fobjc-arc"
    }
}

lm.antdir = lm.antdir or "3rd/ant/"

lm:import(lm.antdir .. "make.lua")
lm:import "clibs/make.lua"

if lm.os == "windows" then
    lm:copy "fmod_dll" {
        input = {
            lm.antdir .. "3rd/fmod/windows/core/lib/x64/fmodL.dll",
            lm.antdir .. "3rd/fmod/windows/studio/lib/x64/fmodstudioL.dll",
        },
        output = {
            lm.bindir .. "/fmodL.dll",
            lm.bindir .. "/fmodstudioL.dll",
        },
    }
end

lm:copy "copy_luaecs" {
    input = lm.antdir .. "3rd/luaecs/ecs.lua",
    output = "packages/ecs/ecs.lua",
}

lm:copy "copy_json" {
    input = lm.antdir .. "packages/json/json.lua",
    output = "packages/resources/ui/json.lua",
}

lm:default {
    lm.os == "windows" and "fmod_dll",
    "copy_luaecs",
    "copy_json",
    "vaststars"
}
