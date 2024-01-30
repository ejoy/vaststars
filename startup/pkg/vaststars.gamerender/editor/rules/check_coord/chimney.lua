local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local iprototype_cache = require "gameplay.prototype_cache.init"
local ifluidbox = ecs.require "render_updates.fluidbox"
local CONSTANT <const> = require "gameplay.interface.constant"
local DIRECTION <const> = CONSTANT.DIRECTION

return function (x, y, dir, typeobject, exclude_coords)
    local t = iprototype_cache.get("recipe_config").chimney_recipes[typeobject.name]
    if not t then
        return false, "unknown"
    end

    for _, conn in ipairs(typeobject.fluidbox.connections) do
        local dx, dy, dir = ifluidbox.rotate(conn.position, DIRECTION[dir], typeobject.area)
        dx, dy = iprototype.move_coord(x + dx, y + dy, dir, 1)
        local fluid = ifluidbox.get(dx, dy, iprototype.reverse_dir(dir))
        if fluid then
            local typeobject = assert(iprototype.queryById(fluid))
            if not t[typeobject.name] then
                return false, "chimneys cannot emit liquids"
            end
        end
    end

    return true
end