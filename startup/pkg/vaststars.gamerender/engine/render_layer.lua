local ecs = ...
local world = ecs.world
local w = world.w

local irl = ecs.require "ant.render|render_layer"
local render_layer_def = require "render_layer_def"

local RENDER_LAYER = {}

local function init(layers)
    local idx = 0
    local function new_layer_name()
        idx = idx + 1
        return ("custom_%d"):format(idx)
    end

    for _, v in ipairs(layers) do
        local after = v[1]
        for i = 2, #v do
            local new = new_layer_name()
            for _, name in ipairs(v[i]) do
                RENDER_LAYER[name] = new
            end
            irl.add_layers(irl.layeridx(after), new)
            after = new
        end
    end
end
init(render_layer_def)

return {
    RENDER_LAYER = RENDER_LAYER,
}