local lm = require "luamake"

lm.mode = "debug"
lm.bindir = "bin/"..lm.mode

lm:import "3rd/ant/make.lua"
lm:import "clibs/make.lua"

if lm.os == "windows" then
    lm:copy "fmod_dll" {
        input = {
            "3rd/ant/3rd/fmod/windows/core/lib/x64/fmodL.dll",
            "3rd/ant/3rd/fmod/windows/studio/lib/x64/fmodstudioL.dll",
        },
        output = {
            lm.bindir .. "/fmodL.dll",
            lm.bindir .. "/fmodstudioL.dll",
        },
    }
end

lm:default {
    lm.os == "windows" and "fmod_dll",
    "vaststars"
}
