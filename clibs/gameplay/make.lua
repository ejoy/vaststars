local lm = require "luamake"

lm:build "compile_entity" {
    "$luamake", "lua", "clibs/gameplay/compile_entity.lua",
    input = {
        "../../clibs/gameplay/compile_entity.lua",
        "../../packages/gameplay/init/component.lua",
    },
    output = "../../clibs/gameplay/src/entity.h",
}

local rootdir = "../../"
local ant3rd = rootdir .. lm.antdir .. "/3rd/"
local lua_include = rootdir .. lm.antdir .. "clibs/lua/"

lm:lib "gameplay" {
    cxx = "c++20",
    deps = "compile_entity",
    includes = {
        ant3rd .. "luaecs",
        lua_include,
    },
    sources = {
        "src/*.c",
        "src/*.cpp",
    }
}
