local lm = require "luamake"

lm:required_version "1.4"

lm.mode = "debug"
--lm.optimize = "speed"
lm.compile_commands = "build"
lm.visibility = "default"

lm.AntDir = lm:path "3rd/ant"

lm.c = "c17"
lm.cxx = "c++20"
if lm.os == "ios" then
    lm.arch = "arm64"
    lm.sys = "ios15.0"
elseif lm.os == "macos" then
    lm.sys = "macos13.0"
end

lm:config "game_config" {
    msvc = {
        flags = "/utf-8",
    },
}

lm.ios = {
    flags = {
        "-fembed-bitcode",
        "-fobjc-arc"
    }
}

lm.android  = {
    flags = "-fPIC",
}

if lm.os == "android" then
    lm.arch = "aarch64"
    lm.vendor = "linux"
    lm.sys = "android33"
end

local plat = (function ()
    if lm.os == "windows" then
        if lm.compiler == "gcc" then
            return "mingw"
        end
        return "msvc"
    end
    if lm.os == "android" then
        return lm.os.."-"..lm.arch
    end
    return lm.os
end)()
lm.builddir = ("build/%s/%s"):format(plat, lm.mode)
lm.bindir = ("bin/%s/%s"):format(plat, lm.mode)

lm.configs = {
    "game_config",
}

local EnableSanitize = false

if EnableSanitize then
    lm.builddir = ("build/%s/sanitize"):format(plat)
    lm.bindir = ("bin/%s/sanitize"):format(plat)
    lm.mode = "debug"
    lm:config "sanitize" {
        flags = "-fsanitize=address",
        gcc = {
            ldflags = "-fsanitize=address"
        },
        clang = {
            ldflags = "-fsanitize=address"
        }
    }
    lm.configs = {
        "game_config",
        "sanitize"
    }
    lm:msvc_copydll "copy_asan" {
        type = "asan",
        output = lm.bindir,
    }
end

lm:import(lm.AntDir .. "/make.lua")
lm:import "clibs/make.lua"

if lm.os == "windows" then
    lm:copy "copy_dll" {
        input = {
            lm.AntDir .. "/3rd/fmod/windows/core/lib/x64/fmod.dll",
            lm.AntDir .. "/3rd/fmod/windows/studio/lib/x64/fmodstudio.dll",
            lm.AntDir .. "/3rd/vulkan/x64/vulkan-1.dll",
        },
        output = {
            lm.bindir .. "/fmod.dll",
            lm.bindir .. "/fmodstudio.dll",
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
    "vaststars_rt_static",
    "vaststars_rt",
    "vaststars",
}
