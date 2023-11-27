local i = 1
while true do
    if arg[i] == '-E' then
    elseif arg[i] == '-e' then
        i = i + 1
        assert(arg[i], "'-e' needs argument")
        load(arg[i], "=(expr)")()
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
if arg[#arg] == "-s" then
    arg[0] = "3rd/ant/tools/fileserver/main.lua"
    arg[1] = "../../startup"
    arg[2] = nil
elseif arg[#arg] == "-p" then
    arg[0] = "3rd/ant/tools/filepack/main.lua"
    arg[1] = "../../startup"
    arg[2] = nil
elseif arg[#arg] == "-e" then
    arg[0] = "3rd/ant/tools/editor/main.lua"
    arg[1] = nil
elseif arg[0] == nil or arg[0] == "" then
    arg[0] = "startup/main.lua"
end

local MainPath = fs.relative(ProjectDir / arg[0], antdir)
arg[0] = MainPath:string()

assert(loadfile(arg[0]))(table.unpack(arg))
