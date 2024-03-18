local function LoadFile(path, env)
    local fastio = require "fastio"
    local data = fastio.readall_v(path, path)
    if not data then
        error(('%s:No such file or directory.'):format(path))
    end
    local func, err = fastio.loadlua(data, path, env)
    if not func then
        error(err)
    end
    return func
end

local function LoadDbg(expr)
    local env = setmetatable({}, {__index = _G})
    function env.dofile(path)
        return LoadFile(path, env)()
    end
    assert(load(expr, "=(expr)", "t", env))()
end

local i = 1
while true do
    if arg[i] == '-E' then
    elseif arg[i] == '-e' then
        i = i + 1
        assert(arg[i], "'-e' needs argument")
        LoadDbg(arg[i])
    else
        break
    end
    i = i + 1
end

for j = -1, #arg do
    arg[j - i] = arg[j]
end
for j = #arg - i + 1, #arg do
    arg[j] = nil
end

local fs = require "bee.filesystem"
local ProjectDir = fs.exe_path()
    :parent_path()
    :parent_path()
    :parent_path()
    :parent_path()

local antdir = os.getenv "antdir"
antdir = antdir and fs.path(antdir) or (ProjectDir / "3rd" / "ant")

fs.current_path(antdir)
if arg[0] == "-s" then
    arg[0] = "3rd/ant/tools/fileserver/main.lua"
    table.insert(arg, 1, "../../startup")
elseif arg[0] == "-p" then
    arg[0] = "3rd/ant/tools/filepack/main.lua"
    table.insert(arg, 1, "../../startup")
elseif arg[0] == "-d" then
    arg[0] = "3rd/ant/tools/editor/main.lua"
    table.insert(arg, 1, "../../startup")
elseif arg[0] == nil or arg[0] == "" then
    arg[0] = "startup/main.lua"
elseif arg[0]:sub(1,1) == "-" then
	table.move(arg, 0, #arg, 1)
	arg[0] = "startup/main.lua"
end

local MainPath = fs.relative(ProjectDir / arg[0], antdir)
arg[0] = MainPath:string()

LoadFile(arg[0])(table.unpack(arg))
