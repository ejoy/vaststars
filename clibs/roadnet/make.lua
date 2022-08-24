local lm = require "luamake"

local antdir = "../../" .. lm.antdir

lm:lib "roadnet" {
    cxx = "c++20",
    includes = {
        antdir .. "clibs/lua/",
    },
    sources = {
        "/**/*.c",
        "/**/*.cpp",
    }
}
