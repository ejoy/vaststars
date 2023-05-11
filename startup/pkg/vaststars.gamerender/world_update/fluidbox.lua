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

local function __print_debug(e, fluid) -- TODO: remove this
    local pt = iprototype.queryById(fluid)
    print(("fluidbox: %d %d %s %s"):format(e.building.x, e.building.y, DIRECTION[e.building.direction], pt.name))
    io.flush()
end

local function __update_neighbor(gameplay_world, e, typeobject)
    local need_build = false

    assert(e.fluidbox.fluid ~= 0)
    local fluid = e.fluidbox.fluid
    for _, connection in ipairs(typeobject.fluidbox.connections) do
        local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)
        x, y = x + e.building.x, y + e.building.y
        local succ
        succ, x, y = terrain:move_coord(x, y, dir, 1)
        if succ then
            local object = objects:coord(x, y)
            if object then
                local neighbor = assert(gameplay_world.entity[object.gameplay_eid])
                if neighbor.fluidbox then
                    local neighbor_fluid = neighbor.fluidbox.fluid or 0
                    assert(neighbor_fluid == fluid or neighbor_fluid == 0)
                    if neighbor_fluid == 0 then
                        __print_debug(neighbor, fluid)
                        ifluidbox.update_fluidbox(neighbor, fluid)
                        __update_neighbor(gameplay_world, neighbor, iprototype.queryById(neighbor.building.prototype))
                        need_build = true
                    end
                end
            end
        end
    end
    return need_build
end

return function(gameplay_world)
    local need_build = false
    for e in gameplay_world.ecs:select "building_changed:in building:in fluidbox:update fluidbox_changed?out eid:in" do
        local typeobject = iprototype.queryById(e.building.prototype)
        local fluid = e.fluidbox.fluid or 0

        if fluid == 0 then
            local fluids = {}
            for _, connection in ipairs(typeobject.fluidbox.connections) do
                local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)
                x, y = x + e.building.x, y + e.building.y
                local succ
                succ, x, y = terrain:move_coord(x, y, dir, 1)
                if succ then
                    local object = objects:coord(x, y)
                    if object then
                        local neighbor = assert(gameplay_world.entity[object.gameplay_eid])
                        if neighbor.fluidbox then
                            local neighbor_fluid = neighbor.fluidbox.fluid or 0
                            if neighbor_fluid ~= 0 then
                                fluids[neighbor_fluid] = true
                            end
                        end
                    end
                end
            end
            assert(__length(fluids) <= 1)
            if __length(fluids) == 1 then
                local fluid = next(fluids)
                __print_debug(e, fluid)
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