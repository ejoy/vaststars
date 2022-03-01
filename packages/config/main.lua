local fs = require "filesystem"
local exclude = {
    ["main"] = true,
    ["package"] = true,
}

local m = {}
for file in fs.pairs(fs.path "/pkg/vaststars.config/lua/") do
    local s = file:stem():string()
    if not exclude[s] then
        m[s] = require("lua." .. s)
    end
end
return m
