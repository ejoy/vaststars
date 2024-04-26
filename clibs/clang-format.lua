local fs = require "bee.filesystem"
local sp = require "bee.subprocess"

local EXTENSION <const> = {
    [".h"] = true,
    [".c"] = true,
    [".cpp"] = true,
}

local IGNORE <const> = {
    ["clibs/gameplay/src/util/sort_r.h"] = true,
    ["clibs/gameplay/src/core/fluidflow.h"] = true,
    ["clibs/gameplay/src/core/fluidflow.c"] = true,
    ["clibs/gameplay/src/core/heatnet.h"] = true,
    ["clibs/gameplay/src/core/heatnet.c"] = true,
}

local sourcefile = {}

local function scan(dir)
    for path, status in fs.pairs(dir) do
        if status:is_directory() then
            scan(path)
        else
            local ext = path:extension()
            if EXTENSION[ext] and not IGNORE[path:string()] then
                print(path:string())
                sourcefile[#sourcefile+1] = path:string()
            end
        end
    end
end

scan "clibs"

if #sourcefile > 0 then
    local process = assert(sp.spawn {
        "luamake", "shell", "clang-format",
        "-i", sourcefile,
        stdout = io.stdout,
        stderr = "stdout",
        searchPath = true,
    })
    local code = process:wait()
    if code ~= 0 then
        os.exit(code, true)
    end
end
