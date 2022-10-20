local lm = require "luamake"

lm:lua_source "roadnet" {
    cxx = "c++20",
    sources = {
        "*.c",
        "*.cpp",
    }
}
