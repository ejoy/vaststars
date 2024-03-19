local fs = require "filesystem"

local on = {}
for file in fs.pairs(fs.path "/pkg/vaststars.ui/on") do
    local s = file:stem():string()
    on[s] = assert(require("on." .. s))
end

return {
    ui_system = require "ui_system",
    scrolltoitem = require "scrolltoitem",
    list = require "list",
    page = require "page",
    on = on,
}
