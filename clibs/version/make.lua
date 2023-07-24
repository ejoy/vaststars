local lm = require "luamake"

if lm.os == "ios" and lm.mode == "release" then
    os.execute "touch clibs/version/update_version.lua"
    lm:runlua {
        script = "update_version.lua",
        args = { "$out" },
        output = "EmbedVersion.h",
    }
end

lm:phony {
    input = "EmbedVersion.h",
    output = "version.cpp",
}

lm:lua_source "version" {
    cxx = "c++20",
    sources = {
        "version.cpp",
    }
}
