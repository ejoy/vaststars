local lm = require "luamake"

if lm.os == "ios" and lm.mode == "release" then
    os.execute "touch clibs/version/update_version.lua"
end

lm:runlua {
    script = "update_version.lua",
    args = { ".", "$out" },
    outputs = "GameVersion.h",
}

lm:runlua {
    script = "update_version.lua",
    args = { "3rd/ant", "$out" },
    outputs = "EngineVersion.h",
}

lm:phony {
    inputs = {
        "GameVersion.h",
        "EngineVersion.h",
    },
    outputs = "version.cpp",
}

lm:lua_source "version" {
    cxx = "c++20",
    sources = {
        "version.cpp",
    }
}
