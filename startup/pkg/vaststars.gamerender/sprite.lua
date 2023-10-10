local ecs = ...
local world = ecs.world
local w = world.w

local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local CONSTANT <const> = require("gameplay.interface.constant")
local MAP_HEIGHT <const> = CONSTANT.MAP_HEIGHT
local itp = ecs.require "ant.landform|translucent_plane_system"
local CONST = require "gameplay.interface.constant"

local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

local HEIGHT <const> = CONST.MAP_HEIGHT
local OFFSET<const> = CONST.MAP_OFFSET

--x, y base 0
local function __convert_coord(x, y)
    x, y = x, HEIGHT - y - 1
    return x - OFFSET, y - OFFSET
end

return function(x, y, w, h, dir, color)
    local id

    local function create(x, y, w, h, color)
        x, y = __convert_coord(x, y)
        id = itp.create_translucent_plane({x = x, z = y, w = w, h = h}, color, RENDER_LAYER.TRANSLUCENT_PLANE)
    end
    local function remove()
        itp.remove_translucent_plane(id)
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