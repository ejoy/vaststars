local lm = require "luamake"

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
    sources = {
        "version.cpp",
    }
}
