local lm = require "luamake"

lm:runlua "compile_gameplay_ecs" {
    script = "../../clibs/gameplay/compile_ecs.lua",
    input = "../../packages/gameplay/init/component.lua",
    output = "../../clibs/gameplay/src/ecs/component.h",
}

local rootdir = "../../"
local ant3rd = rootdir .. lm.antdir .. "/3rd/"
local lua_include = rootdir .. lm.antdir .. "clibs/lua/"

lm:lib "gameplay" {
    cxx = "c++20",
    deps = "compile_gameplay_ecs",
    includes = {
        ant3rd .. "luaecs",
        lua_include,
        "src/"
    },
    sources = {
        "src/**/*.c",
        "src/**/*.cpp",
        "!src/core/road.c",
        "!src/core/mining.cpp",
    }
}
