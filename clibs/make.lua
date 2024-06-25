local lm = require "luamake"

lm:import "gameplay/make.lua"

lm:copy "bootstrap_lua" {
    inputs = "bootstrap.lua",
    outputs = "$bin/main.lua",
}

local LuaInclude = lm.AntDir .. "/3rd/bee.lua/3rd/lua"

if lm.os == "ios" then
    lm:lib "vaststars" {
        deps = {
            "ant_runtime",
            "ant_links",
            "gameplay",
        },
        includes = {
            LuaInclude,
            lm.AntDir .. "/runtime/common",
        },
        sources = "vaststars_modules.c"
    }
    return
end

if lm.os == "android" then
    local jniDir
    local arch
    if lm.target then
        arch = lm.target:match "^[^-]*"
    elseif lm.arch then
        arch = lm.arch
    end
    if arch == "aarch64" then
        jniDir = "arm64-v8a"
    elseif arch == "x86_64" then
        jniDir = "x86_64"
    else
        error("unknown arch:" .. tostring(arch))
    end

    lm:dll "vaststars" {
        basename = "libvaststars",
        crt = "static",
        bindir = "runtime/android/app/src/main/jniLibs/" .. jniDir,
        deps = {
            "ant_runtime",
            "ant_links",
            "bgfx-lib",
            "gameplay",
        },
        ldflags = "-Wl,--no-undefined",
        includes = {
            LuaInclude,
            lm.AntDir .. "/runtime/common",
        },
        sources = "vaststars_modules.c",
    }
    return
end

if lm.os == "macos" then
    lm:lua_dll "vaststars" {
        export_luaopen = "off",
        deps = {
            "gameplay",
        }
    }
    return
end

lm:lua_dll "vaststars" {
    export_luaopen = "off",
    deps = {
        "gameplay",
    },
    includes = {
        lm.AntDir .. "/3rd/bee.lua/",
    },
    sources = {
        "gameplay/gameplay.def",
        lm.AntDir .. "/3rd/bee.lua/bee/win/wtf8.cpp",
    },
}
