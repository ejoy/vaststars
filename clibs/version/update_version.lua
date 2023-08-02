local output = ...
local subprocess = require "bee.subprocess"

local function GitVersion(path)
    local prog = subprocess.spawn {
        "git", "rev-parse", "HEAD",
        cwd = path,
        stdout = true,
        searchPath = true,
    }
    if not prog then
        return ""
    end
    if 0 ~= prog:wait() then
        return ""
    end
    local data = prog.stdout:read "a"
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
