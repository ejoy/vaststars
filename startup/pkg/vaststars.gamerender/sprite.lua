local ecs = ...
local world = ecs.world
local w = world.w

local itp = ecs.import.interface "mod.translucent_plane|itranslucent_plane"
local iroad = ecs.require "engine.road"

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
        local t = {}
        for i = 0, w-1 do
            for j = 0, h-1 do
                t[#t+1] = {x + i, y - j}
            end
        end
        id = itp.create_translucent_plane_entity(t, color)
    end
    local function remove()
        itp.remove_translucent_plane_entity(id)
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