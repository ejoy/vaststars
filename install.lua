-- .\bin\msvc\release\vaststars.exe install.lua %*

local ant_dir = ""
local path_sep = package.config:sub(3,3)
if package.cpath:match(path_sep) then
	local ext = package.cpath:match '[/\\]%?%.([a-z]+)'
	package.cpath = (function ()
		local i = 0
		while arg[i] ~= nil do
			i = i - 1
		end
		local dir = arg[i + 1]:match("(.+)[/\\][%w_.-]+$")
		return ("%s/?.%s"):format(dir, ext)
	end)()
end

local fs = require "bee.filesystem"
local bytecode = dofile(ant_dir .. "tools/install/bytecode.lua")
local argument = dofile(ant_dir .. "packages/argument/main.lua")

local function copy_directory(from, to, filter)
    fs.create_directories(to)
    for fromfile in fs.pairs(from) do
        if (not filter) or filter(fromfile) then
            if fs.is_directory(fromfile) then
                copy_directory(fromfile, to / fromfile:filename(), filter)
            else
                if argument["bytecode"] and fromfile:equal_extension ".lua" then
                    bytecode(fromfile, to / fromfile:filename())
                else
                    fs.copy_file(fromfile, to / fromfile:filename(), fs.copy_options.overwrite_existing)
                end
            end
        end
    end
end

local BIN = fs.exe_path():parent_path()
local input = BIN / "../../../"
local output = BIN / "../../../../vaststars-release"
local PLAT = BIN:parent_path():filename():string()

local dirs = {"bin", "packages"}

print "remove vaststars-release/* ..."
if fs.exists(output) then
    for _, v in ipairs(dirs) do
	fs.remove_all(output / v)
    end
else
    fs.create_directories(output)
end

print "copy data to vaststars-release/* ..."

local directory = {
    {
        source = BIN, dest = output / "bin/msvc/release", func = function(path)
            return path:equal_extension '.dll' or path:equal_extension'.exe' or path:equal_extension'.lua'
        end,
    },
    {
        source = input / "packages", dest = output / "packages", func = function(path)
            return path:filename():string() ~= ".gitignore"
        end,
    },
    {
        source = input / "startup", dest = output / "startup", func = function(path)
            return true
        end,
    }
}
for _, v in ipairs(directory) do
    copy_directory(v.source, v.dest, v.func)
end

local files = {"run.bat", "run_editor.bat", "clean.bat"}
for _, file in ipairs(files) do
	fs.copy_file(input / file, output / file, fs.copy_options.overwrite_existing)
end

if PLAT == "msvc" then
    print "copy msvc depend dll"
    local msvc = dofile "tools/install/msvc_helper.lua"
    msvc.copy_vcrt("x64", output / "bin/msvc/release")
end

local function check_need_submit(...)
    for i=1, select('#', ...) do
        local a = select(1, ...)
        if a:match "submit" then
            return true
        end
    end
end

if check_need_submit(...) then
    print "submit vaststars-release ..."

    local subprocess = require "bee.subprocess"

    local cwd<const> = "../vaststars-release"
    local function spawn(cmd)
        print("spawn process:", cmd .. table.concat(cmd, " "))
        cmd.stdout = true
        cmd.stderr = true
        local p = subprocess.spawn(cmd)

        if p.stdout then
            print("stdout:", p.stdout:read "a")
        end

        if p.stderr then
            print("stderr:", p.stderr:read "a")
        end

        local errcode = p:wait()
        if errcode ~= 0 then
            print("error:", errcode)
        end
    end

    spawn{"git", "add", "."}
    local function find_commit_msg_in_arg(...)
        for i=1, select('#', ...) do
            local a = select(1, ...)
            local msg = a:match"commitmsg=(.+)"
            if msg then
                return msg
            end
        end
    end
    local commitmsg = find_commit_msg_in_arg(...) or "new"
    spawn{"git", "commit", "-m", commitmsg, "."}
    spawn{"git", "push"}
end