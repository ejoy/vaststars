local lm = require "luamake"

if lm.os == "ios" and lm.mode == "release" then
    os.execute "touch clibs/version/update_version.lua"
end

lm:runlua {
    script = "update_version.lua",
    args = { ".", "$out" },
    output = "GameVersion.h",
}

lm:runlua {
    script = "update_version.lua",
    args = { "3rd/ant", "$out" },
    output = "EngineVersion.h",
}

lm:phony {
    input = {
        "GameVersion.h",
        "EngineVersion.h",
    },
    output = "version.cpp",
}

lm:lua_source "version" {
    cxx = "c++20",
    sources = {
        "version.cpp",
    }
}
