if arg[1] == "-s" then
    arg[0] = "3rd/ant/tools/fileserver/main.lua"
    arg[1] = "../../startup"
elseif arg[1] == "-p" then
    arg[0] = "3rd/ant/tools/filepack/main.lua"
    arg[1] = "../../startup"
elseif arg[1] == "-d" then
    arg[0] = "3rd/ant/tools/editor/main.lua"
    arg[1] = "../../startup"
elseif arg[1] == nil or arg[1] == "" then
    arg[0] = "startup/main.lua"
else
    arg[0] = table.remove(arg, 1)
end

local fs = require "bee.filesystem"
local sys = require "bee.sys"
local ProjectDir = sys.exe_path()
    :parent_path()
    :parent_path()
    :parent_path()
    :parent_path()
fs.current_path(ProjectDir / "3rd" / "ant")
arg[0] = (ProjectDir / arg[0]):string()

dofile "/engine/console/bootstrap.lua"
