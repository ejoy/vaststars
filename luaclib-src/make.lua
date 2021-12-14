local lm = require "luamake"
local third_party_path = "../3rd/"

dofile "common.lua"

lm:source_set "luaclib" {
    includes = LuaInclude,
    sources = {
        "*.c",
    },
    windows = {
        sources = {
        },
        links = {
            "ws2_32"
        }
    }
}

lm:lua_dll "luaclib" {
    deps = "luaclib"
}
