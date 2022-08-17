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

if lm.os == "ios" then
    lm:lib "vaststars" {
        deps = {
            "ant_runtime",
            "bgfx-lib",
            "ant_links",
            modules
        },
        includes = {
            Antdir .. "clibs/lua",
            Antdir .. "runtime/common",
        },
        sources = "vaststars_modules.c"
    }
    return
end

if lm.os ~= "ios" then
    lm:exe "vaststars" {
        deps = {
            "ant_editor",
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
end

lm:exe "vaststars_rt" {
    deps = {
        "ant_runtime",
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
