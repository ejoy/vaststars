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

if lm.mode == "debug" then
    --lm.flags = "-fsanitize=address"
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

lm:copy "copy_manual" {
    input = "startup/test_manual.lua",
    output = "packages/gamerender/gameplay/interface/manual.lua",
}

lm:default {
    lm.os == "windows" and "fmod_dll",
    lm.compiler == "msvc" and lm.mode == "debug" and "copy_asan",
    "copy_manual",
    "vaststars"
}
