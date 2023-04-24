local ecs = ...
local world = ecs.world
local w = world.w

local irl = ecs.import.interface "ant.render|irender_layer"

local RENDER_LAYER = {}

local function init(layers)
    local idx = 0
    local function new_layer_name()
        idx = idx + 1
        return ("custom_%d"):format(idx)
    end

    for _, v in ipairs(layers) do
        local after = v[1]
        local new = new_layer_name()

        local names = {}
        for i = 2, #v do
            names[#names + 1] = new
            for _, name in ipairs(v[i]) do
                RENDER_LAYER[name] = new
            end
        end
        irl.add_layers(irl.layeridx(after), table.unpack(names))
    end
end

return {
    init = init,
    RENDER_LAYER = RENDER_LAYER,
}