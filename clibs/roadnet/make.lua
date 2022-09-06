local lm = require "luamake"

local antdir = "../../" .. lm.antdir

lm:source_set "roadnet" {
    cxx = "c++20",
    includes = {
        antdir .. "clibs/lua/",
    },
    sources = {
        "*.c",
        "*.cpp",
    }
}
