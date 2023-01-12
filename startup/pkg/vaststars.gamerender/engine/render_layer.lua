local ecs = ...
local world = ecs.world
local w = world.w

local renderpkg = import_package "ant.render"
local rl = renderpkg.layer

local RENDER_LAYER = {}

local function init(layers)
    for _, v in ipairs(layers) do
        rl.add_layer(v[1], rl.layeridx(v[2]))
        for _, name in ipairs(v[3]) do
            RENDER_LAYER[name] = v[1]
        end
    end
end

return {
    init = init,
    RENDER_LAYER = RENDER_LAYER,
}