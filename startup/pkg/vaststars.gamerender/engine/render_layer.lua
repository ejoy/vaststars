local ecs = ...
local world = ecs.world
local w = world.w

local irl = ecs.import.interface "ant.render|irender_layer"

local RENDER_LAYER = {}

local function init(layers)
    for _, v in ipairs(layers) do
        local layer_name = v[1]
        local names = {}

        for i = 2, #v do
            names[#names + 1] = v[i].layer_name

            for _, name in ipairs(v[i].logic_layer_names) do
                RENDER_LAYER[name] = v[i].layer_name
            end
        end
        irl.add_layers(irl.layeridx(layer_name), table.unpack(names))
    end
end

return {
    init = init,
    RENDER_LAYER = RENDER_LAYER,
}