local lm = require "luamake"

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
        "src/roadnet",
        lm.AntDir .. "/3rd/luaecs",
        lm.AntDir .. "/3rd/bee.lua",
        lm.AntDir .. "/clibs/ecs/",
        lm.AntDir .. "/pkg/ant.scene/",
    },
    sources = {
        "src/**/*.c",
        "src/**/*.cpp",
        "!src/core/road.c",
        "!src/core/mining.cpp",
    }
}
