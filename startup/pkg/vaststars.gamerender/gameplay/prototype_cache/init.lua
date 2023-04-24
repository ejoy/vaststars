local fs = require "filesystem"

local cache = {}

local function reload()
    cache = {}

    for file in fs.pairs(fs.path "/pkg/vaststars.gamerender/gameplay/prototype_cache") do
        local s = file:stem():string()
        if s ~= "init" then
            cache[s] = assert(require("gameplay.prototype_cache." .. s))()
        end
    end
end

return {
    reload = reload,
    get = function(name)
        return cache[name]
    end,
}