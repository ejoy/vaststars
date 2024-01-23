local input, output = ...
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
f:write('"')
f:write(GitVersion(input))
f:write('"')
