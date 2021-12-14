local lm = require "luamake"

dofile "../common.lua"

lm:lib "gameplay" {
    cxx = "c++20",
    includes = {
        Ant3rd .. "luaecs",
        LuaInclude,
    },
    sources = {
        "src/*.c",
        "src/*.cpp",
    }
}
