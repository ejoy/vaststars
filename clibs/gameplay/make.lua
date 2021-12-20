local lm = require "luamake"

dofile "../common.lua"

lm:build "compile_entity" {
    "$luamake", "lua", "clibs/gameplay/compile_entity.lua"
}

lm:lib "gameplay" {
    cxx = "c++20",
    deps = "compile_entity",
    includes = {
        Ant3rd .. "luaecs",
        LuaInclude,
    },
    sources = {
        "src/*.c",
        "src/*.cpp",
    }
}
