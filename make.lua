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
elseif lm.os == "macos" then
    lm.sys = "macos11.0"
end

lm.ios = {
    flags = {
        "-fembed-bitcode",
        "-fobjc-arc"
    }
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

    lm:copy "vulkan_dll" {
        input = {
            lm.antdir .. "3rd/vulkan/x64/vulkan-1.dll",
        },
        output = {
            lm.bindir .. "/vulkan-1.dll",
        },
    }

    lm:copy "vulkan_ant_dll" {
        input = {
            lm.antdir .. "3rd/vulkan/x64/vulkan-1.dll",
        },
        output = {
            lm.antdir .. "bin/msvc/debug/vulkan-1.dll"
        },
    }

    lm:phony "phony_windows" {
        deps = {
            "fmod_dll",
            "vulkan_dll",
            "vulkan_ant_dll",
            lm.compiler == "msvc" and EnableSanitize and "copy_asan",
        }
    }
end

if lm.os == "ios" then
    lm:phony "phony_ios" {
        deps = {
            "bgfx-lib",
        }
    }
end

lm:default {
    lm.os == "windows" and "phony_windows",
    lm.os == "ios" and "phony_ios",
    lm.os ~= "ios" and "vaststars_rt",
    "vaststars",
}
