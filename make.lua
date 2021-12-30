local lm = require "luamake"

local fs = require "bee.filesystem"

lm.mode = "debug"
lm.bindir = "bin/msvc/"..lm.mode

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

lm:default {
    lm.os == "windows" and "fmod_dll",
    "copy_luaecs",
    "vaststars"
}
