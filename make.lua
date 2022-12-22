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
lm.compile_commands = "build"
lm.visibility = "default"

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

local EnableSanitize = false -- true
if EnableSanitize then
    lm.builddir = ("build/%s/sanitize"):format(plat)
    lm.mode = "debug"
    lm.flags = "-fsanitize=address"
    lm.msvc = {
        defines = "_DISABLE_STRING_ANNOTATION"
    }
    lm:msvc_copydll "copy_asan" {
        type = "asan",
        output = lm.bindir,
    }
end

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

if lm.os == "windows" then
    lm:copy "vulkan_dll" {
        input = {
            lm.antdir .. "3rd/vulkan/x64/vulkan-1.dll",
        },
        output = {
            lm.bindir .. "/vulkan-1.dll",
        },
    }
end

lm:default {
    lm.os == "windows" and "fmod_dll" and "vulkan_dll",
    lm.compiler == "msvc" and EnableSanitize and "copy_asan",
    "vaststars",
    lm.os == "ios" and "bgfx-lib",
    lm.os ~= "ios" and "vaststars_rt",
}
