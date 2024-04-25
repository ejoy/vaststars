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
    lm:lib "vaststars_static" {
        deps = {
            "ant_runtime",
            "ant_links",
            "bootstrap_lua",
            "gameplay",
        },
        includes = {
            LuaInclude,
            lm.AntDir .. "/runtime/common",
        },
        sources = "vaststars_modules.c"
    }

    lm:exe "vaststars" {
        deps = {
            "ant_runtime",
            "bgfx-lib",
            "ant_links",
            "bootstrap_lua",
            "gameplay",
        },
        includes = {
            LuaInclude,
            lm.AntDir .. "/runtime/common",
        },
        msvc = {
            defines = "LUA_BUILD_AS_DLL",
        },
        sources = "vaststars_modules.c"
    }
    return
end

lm:exe "vaststars" {
    deps = {
        "ant_runtime",
        "bgfx-lib",
        "ant_links",
        "bootstrap_lua",
        "gameplay",
    },
    includes = {
        LuaInclude,
        lm.AntDir .. "/runtime/common",
    },
    msvc = {
        defines = "LUA_BUILD_AS_DLL",
    },
    sources = {
        "vaststars_modules.c",
        lm.AntDir .. "/runtime/windows/lua.rc"
    }
}
