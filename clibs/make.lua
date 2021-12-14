local lm = require "luamake"

lm:import "gameplay/make.lua"

Ant = "../3rd/ant/"

lm:copy "mainlua" {
    input = Ant .. "runtime/common/main.lua",
    output = "../"..lm.bindir,
}

local modules = {
    "gameplay"
}

lm:exe "vaststars" {
    deps = {
        "bgfx-lib",
        "ant_editor",
        --"ant_runtime",
        "ant_links",
        "mainlua",
        modules
    },
    includes = {
        Ant .. "clibs/lua",
        Ant .. "runtime/common",
    },
    sources = "vaststars_modules.c"
}
