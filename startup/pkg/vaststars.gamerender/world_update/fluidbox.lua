local ecs = ...
local world = ecs.world
local w = world.w
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local terrain = ecs.require "terrain"
local gameplay = import_package "vaststars.gameplay"
local ifluidbox = gameplay.interface "fluidbox"

local DIRECTION <const> = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
    [0] = 'N',
    [1] = 'E',
    [2] = 'S',
    [3] = 'W',
}

local function __length(t)
    local n = 0
    for _ in pairs(t) do
        n = n + 1
    end
    return n
end

local function __print_debug(prefix, e, fluid) -- TODO: remove this
    local pt = iprototype.queryById(fluid)
    print(("%s fluidbox: %d %d %s %s"):format(prefix, e.building.x, e.building.y, DIRECTION[e.building.direction], pt.name))
    io.flush()
end

local function __find_neighbor(x, y, dir, ground)
    local succ, dx, dy = false, x, y
    for i = 1, ground or 1 do
        succ, dx, dy = terrain:move_coord(dx, dy, dir, 1)
        if not succ then
            return
        end

        local object = objects:coord(dx, dy)
        if object then
            return object
        end
    end
end

local function __update_neighbor(gameplay_world, e, typeobject)
    local need_build = false

    assert(e.fluidbox.fluid ~= 0)
    local fluid = e.fluidbox.fluid
    for _, connection in ipairs(typeobject.fluidbox.connections) do
        local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)
        local neighbor_object = __find_neighbor(e.building.x + x, e.building.y + y, dir, connection.ground)
        if neighbor_object then
            local neighbor = assert(gameplay_world.entity[neighbor_object.gameplay_eid])
            if neighbor.fluidbox then
                local neighbor_fluid = neighbor.fluidbox.fluid or 0
                assert(neighbor_fluid == fluid or neighbor_fluid == 0)
                if neighbor_fluid == 0 then
                    __print_debug("test2", neighbor, fluid)
                    ifluidbox.update_fluidbox(neighbor, fluid)
                    __update_neighbor(gameplay_world, neighbor, iprototype.queryById(neighbor.building.prototype))
                    need_build = true
                end
            end
        end
    end
    return need_build
end

return function(gameplay_world)
    local need_build = false
    for e in gameplay_world.ecs:select "building_changed:in building:in fluidbox:update fluidbox_changed?update eid:in" do
        local typeobject = iprototype.queryById(e.building.prototype)
        local fluid = e.fluidbox.fluid or 0

        if fluid == 0 then
            local fluids = {}
            for _, connection in ipairs(typeobject.fluidbox.connections) do
                local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)
                local neighbor_object = __find_neighbor(e.building.x + x, e.building.y + y, dir, connection.ground)
                if neighbor_object then
                    local neighbor = assert(gameplay_world.entity[neighbor_object.gameplay_eid])
                    if neighbor.fluidbox then
                        local neighbor_fluid = neighbor.fluidbox.fluid or 0
                        if neighbor_fluid ~= 0 then
                            fluids[neighbor_fluid] = true
                        end
                    end
                end
            end
            assert(__length(fluids) <= 1)
            if __length(fluids) == 1 then
                local fluid = next(fluids)
                __print_debug("test1", e, fluid)
                ifluidbox.update_fluidbox(e, fluid)
                __update_neighbor(gameplay_world, e, typeobject)
                need_build = true
            end
        else
            if __update_neighbor(gameplay_world, e, typeobject) then
                need_build = true
            end
        end
    end

    if need_build then
        gameplay_world:build()
    end
end