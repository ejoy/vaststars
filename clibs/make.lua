local lm = require "luamake"

lm:import "gameplay/make.lua"

lm:copy "bootstrap_lua" {
    input = "bootstrap.lua",
    output = "../"..lm.bindir.."/main.lua",
}

local modules = {
    "gameplay"
}

local Antdir = "../" .. lm.antdir

lm:exe "vaststars" {
    deps = {
        lm.os == "ios" and "ant_runtime" or "ant_editor",
        "bgfx-lib",
        "ant_links",
        "bootstrap_lua",
        modules
    },
    includes = {
        Antdir .. "clibs/lua",
        Antdir .. "runtime/common",
    },
    sources = "vaststars_modules.c"
}
