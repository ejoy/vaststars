local m = {}

local core = require "vaststars.container.core"

for _, name in ipairs {"create", "pickup", "place", "at"} do
    local f = core[name]
    local game = require "base.game"
    m[name] = function (...)
        local world = game.world
        return f(world, ...)
    end
end

return m
