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

local antdir = os.getenv "antdir"
local fs = require "bee.filesystem"
antdir = antdir and fs.path(antdir) or (fs.exe_path()
    :parent_path()
    :parent_path()
    :parent_path()
    :parent_path()
    / "3rd"
    / "ant")

fs.current_path(antdir)
if arg[0] == nil then
    arg[0] = "../../main.lua"
end

print("arg[0]", arg[0])
assert(loadfile(arg[0]))(table.unpack(arg))
