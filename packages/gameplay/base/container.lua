local m = {}

local core = require "vaststars.container.core"

for _, name in ipairs {"create", "pickup", "place", "at"} do
    local f = core[name]
    m[name] = function (...)
        local game = require "base.game"
        local world = game.world
        return f(world, ...)
    end
end

return m
