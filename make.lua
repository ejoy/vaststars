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

lm.c = "c17"
lm.cxx = "c++20"
if lm.os == "ios" then
    lm.arch = "arm64"
    if lm.mode == "release" then
        lm.sys = "ios13.0"
    else
        lm.sys = "ios14.1"
    end
elseif lm.os == "macos" then
    lm.sys = "macos11.0"
end

lm.ios = {
    flags = {
        "-fembed-bitcode",
        "-fobjc-arc"
    }
}

lm.android  = {
    flags = "-fPIC",
    target = "aarch64-linux-android33"
}

local EnableSanitize = false
if EnableSanitize then
    lm.builddir = ("build/%s/sanitize"):format(plat)
    lm.bindir = ("bin/%s/sanitize"):format(plat)
    lm.mode = "debug"
    lm:config "sanitize" {
        flags = "-fsanitize=address",
        msvc = {
            defines = "_DISABLE_STRING_ANNOTATION"
        },
        gcc = {
            ldflags = "-fsanitize=address"
        },  
        clang = {
            ldflags = "-fsanitize=address"
        }
    }
    lm.configs = {
        "sanitize"
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
    lm:copy "copy_dll" {
        input = {
            lm.antdir .. "3rd/fmod/windows/core/lib/x64/fmodL.dll",
            lm.antdir .. "3rd/fmod/windows/studio/lib/x64/fmodstudioL.dll",
            lm.antdir .. "3rd/vulkan/x64/vulkan-1.dll",
        },
        output = {
            lm.bindir .. "/fmodL.dll",
            lm.bindir .. "/fmodstudioL.dll",
            lm.bindir .. "/vulkan-1.dll",
        },
    }
    lm:default {
        "copy_dll",
        lm.compiler == "msvc" and EnableSanitize and "copy_asan",
        "vaststars_rt",
        "vaststars",
    }
    return
end

if lm.os == "ios" then
    lm:default {
        "bgfx-lib",
        "vaststars",
    }
    return
end

if lm.os == "android" then
    lm:default {
        "vaststars",
    }
    return
end

lm:default {
    "vaststars_rt",
    "vaststars",
}
