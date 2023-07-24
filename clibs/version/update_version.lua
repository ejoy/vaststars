local output = ...
local subprocess = require "bee.subprocess"

local function GitVersion(path)
    local prog = assert(subprocess.spawn {
        "git", "rev-parse", "HEAD",
        cwd = path,
        stdout = true,
    })
    local data = prog.stdout:read "a"
    assert(0 == prog:wait())
    return data:match "[0-9a-f]+"
end

local f <close> = assert(io.open(output, 'w'))
local function write(data)
    f:write(data)
    f:write "\n"
end

write "#pragma once"
write ""
write(("const char gGameGitVersion[]   = \"%s\";"):format(GitVersion "./"))
write(("const char gEngineGitVersion[] = \"%s\";"):format(GitVersion "3rd/ant/"))
write ""
