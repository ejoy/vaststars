local ecs = ...
local world = ecs.world
local w = world.w

local renderpkg = import_package "ant.render"
local rl = renderpkg.layer

local RENDER_LAYER = {}

local function init(layers)
    local last = "opacity"
    for idx, v in ipairs(layers) do
        for _, name in ipairs(v) do
            RENDER_LAYER[name] = tostring(idx)
        end

        rl.add_layer(tostring(idx), rl.layeridx(last))
        last = tostring(idx)
    end
end

return {
    init = init,
    RENDER_LAYER = RENDER_LAYER,
}