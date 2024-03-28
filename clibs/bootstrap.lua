local arguments = {}
local options = {}
do
    local extra <const> = {
        ["-e"] = true,
    }
    local i = 1
    while true do
        if arg[i] == nil then
            break
        elseif arg[i]:sub(1, 1) == "-" then
            if extra[arg[i]] then
                options[arg[i]] = arg[i+1]
                i = i + 1
            else
                options[arg[i]] = true
            end
        else
            arguments[#arguments+1] = arg[i]
        end
        i = i + 1
    end
end

arg = {}

if options["-s"] then
    arg[0] = "3rd/ant/tools/fileserver/main.lua"
    arg[1] = "../../startup"
elseif options["-p"] then
    arg[0] = "3rd/ant/tools/filepack/main.lua"
    arg[1] = "../../startup"
elseif options["-d"] then
    arg[0] = "3rd/ant/tools/editor/main.lua"
    arg[1] = "../../startup"
elseif arguments[1] == nil then
    arg[0] = "startup/main.lua"
else
    arg[0] = table.remove(arguments, 1)
end

table.move(arguments, 1, #arguments, #arg+1, arg)

options["-s"] = nil
options["-p"] = nil
options["-d"] = nil
for k, v in pairs(options) do
    arg[#arg+1] = k
    if v ~= true then
        arg[#arg+1] = v
    end
end

local fs = require "bee.filesystem"
local ProjectDir = fs.exe_path()
    :parent_path()
    :parent_path()
    :parent_path()
    :parent_path()
fs.current_path(ProjectDir / "3rd" / "ant")
arg[0] = (ProjectDir / arg[0]):string()

dofile "/engine/console/bootstrap.lua"
