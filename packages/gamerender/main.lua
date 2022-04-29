local fs = require "filesystem"

local function get_files(dir)
    local r = {}
    for v in fs.pairs(dir) do
        if fs.is_directory(v) then
            local t = get_files(v)
            table.move(t, 1, #t, #r + 1, r)
        else
            r[#r+1] = v
        end
    end
    return r
end

local function escape_pattern(s)
    return s:gsub("([^%w])", "%%%1")
end

local function relative_path(path, base_path)
    local pat = ("^%s(.*)$"):format(escape_pattern(base_path))
    return path:match(pat)
end

local function clean_extension(path)
    return path:match("^(.*)%..*$")
end

local M = {
    gameplay = {}
}

local path = "/pkg/vaststars.gamerender/gameplay/"
for _, file in ipairs(get_files(fs.path(path))) do
    local s
    s = relative_path(file:string(), path)
    s = clean_extension(s)
    s = s:gsub("%/", ".")
    M.gameplay[s] = require("gameplay." .. s)
end
return M
