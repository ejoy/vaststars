local lm = require "luamake"

lm:import "src/version/make.lua"

lm:runlua "compile_gameplay_ecs" {
    script = "../../clibs/gameplay/compile_ecs.lua",
    args = {
        lm.AntDir
    },
    inputs = "../../startup/pkg/vaststars.gameplay/init/component.lua",
    outputs = "../../clibs/gameplay/src/util/component.h",
}

lm:lua_source "gameplay" {
    objdeps = "compile_gameplay_ecs",
    includes = {
        "src/",
        lm.AntDir .. "/3rd/luaecs/",
        lm.AntDir .. "/3rd/bee.lua/",
        lm.AntDir .. "/clibs/ecs/",
    },
    sources = {
        "src/**/*.c",
        "src/**/*.cpp",
    }
}
