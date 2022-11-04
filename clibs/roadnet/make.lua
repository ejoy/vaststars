local lm = require "luamake"

lm:lua_source "roadnet" {
    cxx = "c++20",
    includes = {
        "../gameplay/src",
    },
    sources = {
        "*.c",
        "*.cpp",
    }
}
