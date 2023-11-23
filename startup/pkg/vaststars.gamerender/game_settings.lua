local ecs = ...
local world = ecs.world
local w = world.w

local fs = require "filesystem"
local use_config = fs.exists(fs.path("/pkg/vaststars.prototype/debugger.lua"))
local game_settings = use_config and ecs.require("vaststars.prototype|debugger") or {}

local enable = {
    skip_guide = true,
    recipe_unlocked = true,
    item_unlocked = true,
    infinite_item = true,
}

return setmetatable({}, {
    __index = function(_, key)
        if game_settings.enable == true and enable[key] ~= nil then
            return enable[key]
        else
            return game_settings[key]
        end
    end
})