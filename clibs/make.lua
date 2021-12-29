local lm = require "luamake"

lm:import "gameplay/make.lua"

Ant = "../3rd/ant/"

lm:copy "bootstrap_lua" {
    input = "bootstrap.lua",
    output = "../"..lm.bindir.."/main.lua",
}

local modules = {
    "gameplay"
}

lm:exe "vaststars" {
    deps = {
        "ant_editor",
        --"ant_runtime",
        "bgfx-lib",
        "ant_links",
        "bootstrap_lua",
        modules
    },
    includes = {
        Ant .. "clibs/lua",
        Ant .. "runtime/common",
    },
    sources = "vaststars_modules.c"
}
