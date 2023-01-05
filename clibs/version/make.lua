local lm = require "luamake"

if lm.os == "ios" and lm.mode == "release" then
    lm:runlua {
        script = "update_version.lua",
        args = { "$out" },
        output = "../../packages/version/version.lua",
    }
end

lm:runlua {
    script = "../../3rd/ant/clibs/firmware/embed.lua",
    args = { "$in", "$out" },
    input = "../../packages/version/version.lua",
    output = "EmbedVersion.h",
}

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
