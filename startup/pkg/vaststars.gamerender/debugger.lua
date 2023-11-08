local ecs = ...
local world = ecs.world
local w = world.w

local fs = require "filesystem"

local debugger = {}
if fs.exists(fs.path("/pkg/vaststars.prototype/debugger.lua")) then
    debugger = ecs.require "vaststars.prototype|debugger"
end

local options = {
    skip_guide = true,
    recipe_unlocked = true,
    item_unlocked = true,
    infinite_item = true,
}

return setmetatable({}, {
    __index = function(_, k)
        return debugger.enable and options[k] or debugger[k]
    end
})
