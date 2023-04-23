local ecs = ...
local world = ecs.world
local w = world.w

local itp = ecs.import.interface "mod.translucent_plane|itranslucent_plane"
local iroad = ecs.require "engine.road"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

local WIDTH <const> = 256 -- coordinate value range: [0, WIDTH - 1]
local HEIGHT <const> = 256 -- coordinate value range: [0, HEIGHT - 1]
local function __convert_coord(x, y)
    local offset_x, offset_y = iroad:get_offset()
    x, y = x, HEIGHT - y - 1
    return x - offset_x, y - offset_y
end

local function __rotate_area(w, h, dir)
    if dir == 'N' or dir == 'S' then
        return w, h
    elseif dir == 'E' or dir == 'W' then
        return h, w
    end
end

return function(x, y, w, h, dir, color)
    local w, h = __rotate_area(w, h, dir)
    local id

    local function create(x, y, w, h, color)
        x, y = __convert_coord(x, y)
        id = itp.create_translucent_plane({{x = x, z = y, w = w, h = h}}, {color}, RENDER_LAYER.TRANSLUCENT_PLANE)[1]
    end
    local function remove()
        itp.remove_translucent_plane({id})
    end
    local function move(_, x, y, color)
        remove()
        create(x, y, w, h, color)
    end

    create(x, y, w, h, color)
    return {
        remove = remove,
        move = move,
    }
end