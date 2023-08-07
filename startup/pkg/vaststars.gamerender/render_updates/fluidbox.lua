local ecs = ...
local world = ecs.world
local w = world.w

local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local terrain = ecs.require "terrain"
local gameplay = import_package "vaststars.gameplay"
local ifluidbox = gameplay.interface "fluidbox"
local gameplay_core = require "gameplay.core"
local fluidbox_sys = ecs.system "fluidbox_system"

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

local PipeDirection <const> = {
    ["N"] = 0,
    ["E"] = 1,
    ["S"] = 2,
    ["W"] = 3,
}

local N <const> = 0
local E <const> = 1
local S <const> = 2
local W <const> = 3

local FluidboxCache = {}

local function length(t)
    local n = 0
    for _ in pairs(t) do
        n = n + 1
    end
    return n
end

local function pack(x, y, dir)
    return x << 16 | y << 8 | dir
end

local function rotate(position, direction, area)
    local w, h = area >> 8, area & 0xFF
    local x, y = position[1], position[2]
    local dir = (PipeDirection[position[3]] + direction) % 4
    w = w - 1
    h = h - 1
    if direction == N then
        return x, y, dir
    elseif direction == E then
        return h - y, x, dir
    elseif direction == S then
        return w - x, h - y, dir
    elseif direction == W then
        return y, w - x, dir
    end
end

local ifluid = require "gameplay.interface.fluid"
local function __find_neighbor_fluid(gameplay_world, x, y, dir, ground)
    local succ, dx, dy = false, x, y
    for i = 1, ground or 1 do
        succ, dx, dy = terrain:move_coord(dx, dy, dir, 1)
        if not succ then
            return
        end

        local object = objects:coord(dx, dy)
        if object then
            local typeobject = iprototype.queryByName(object.prototype_name)
            if ground then
                if not iprototype.has_type(typeobject.type, "pipe_to_ground") then
                    goto continue
                end
            end

            local fluid_name
            if iprototype.has_type(typeobject.type, "fluidbox") then
                local e = assert(gameplay_world.entity[object.gameplay_eid])
                if e.fluidbox.fluid ~= 0 then
                    fluid_name = iprototype.queryById(e.fluidbox.fluid).name
                end
            elseif iprototype.has_type(typeobject.type, "fluidboxes") then
                fluid_name = {}
                local e = assert(gameplay_world.entity[object.gameplay_eid])

                local io_name = {
                    ["in"] = "input",
                    ["out"] = "output",
                }
                for _, io_type in ipairs({"in", "out"}) do
                    for i = 1, 4 do
                        local n = io_type .. i .. "_fluid"
                        if e.fluidboxes[n] and e.fluidboxes[n] ~= 0 then
                            fluid_name[io_name[io_type]] = fluid_name[io_name[io_type]] or {}
                            fluid_name[io_name[io_type]][i] = iprototype.queryById(e.fluidboxes[n]).name
                        end
                    end
                end
            end
            for _, fb in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir, fluid_name)) do
                if fb.x == dx and fb.y == dy and fb.dir == iprototype.reverse_dir(dir) then
                    return fb.fluid_name, object
                end
            end

            goto continue
        end
        ::continue::
    end
end

local function __update_neighbor_fluid_type(gameplay_world, e, typeobject)
    assert(e.fluidbox.fluid ~= 0)
    local fluid = e.fluidbox.fluid
    for _, connection in ipairs(typeobject.fluidbox.connections) do
        local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)
        local neighbor_fluid_name, neighbor_object = __find_neighbor_fluid(gameplay_world, e.building.x + x, e.building.y + y, dir, connection.ground)
        if (not neighbor_fluid_name or neighbor_fluid_name == "") and neighbor_object then
            local neighbor = assert(gameplay_world.entity[neighbor_object.gameplay_eid])
            if neighbor.fluidbox then
                print("update fluidbox", neighbor.building.x, neighbor.building.y, fluid)
                ifluidbox.update_fluidbox(gameplay_world, neighbor, fluid)
                __update_neighbor_fluid_type(gameplay_world, neighbor, iprototype.queryById(neighbor.building.prototype))
            end
        end
    end
end

function fluidbox_sys:gameworld_prebuild()
    local gameplay_world = gameplay_core.get_world()
    local changed = {}
    for e in gameplay_world.ecs:select "building_new:in fluidbox:in eid:in" do
        changed[e.eid] = true
    end

    for eid in pairs(changed) do
        local e = gameplay_world.entity[eid]
        local typeobject = iprototype.queryById(e.building.prototype)
        local fluid = e.fluidbox.fluid or 0

        if fluid == 0 then
            local fluids = {}
            for _, connection in ipairs(typeobject.fluidbox.connections) do
                local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)
                local neighbor_fluid_name = __find_neighbor_fluid(gameplay_world, e.building.x + x, e.building.y + y, dir, connection.ground)
                print(e.building.x + x, e.building.y + y, neighbor_fluid_name)
                if neighbor_fluid_name and neighbor_fluid_name ~= "" then
                    local neighbor_fluid = iprototype.queryByName(neighbor_fluid_name).id
                    fluids[neighbor_fluid] = true
                end
            end
            assert(length(fluids) <= 1)
            if length(fluids) == 1 then
                local fluid = next(fluids)
                ifluidbox.update_fluidbox(gameplay_world, e, fluid)
                print("update fluidbox", e.building.x, e.building.y, fluid)
                __update_neighbor_fluid_type(gameplay_world, e, typeobject)
            end
        else
            __update_neighbor_fluid_type(gameplay_world, e, typeobject)
        end
    end
end

function fluidbox_sys:gameworld_build()
    local gameplay_world = gameplay_core.get_world()
    FluidboxCache = {}

    for e in gameplay_world.ecs:select "fluidbox:in building:in" do
        local typeobject = iprototype.queryById(e.building.prototype)
        if iprototype.has_type(typeobject.type, "pipe") then
            for _, dir in pairs(PipeDirection) do
                assert(FluidboxCache[pack(e.building.x, e.building.y, dir)] == nil)
                FluidboxCache[pack(e.building.x, e.building.y, dir)] = e.fluidbox.fluid
            end
        elseif iprototype.has_type(typeobject.type, "pipe_to_ground") then
            local dir = (S + e.building.direction) % 4
            assert(FluidboxCache[pack(e.building.x, e.building.y, dir)] == nil)
            FluidboxCache[pack(e.building.x, e.building.y, dir)] = e.fluidbox.fluid
        else
            for _, c in ipairs(typeobject.fluidbox.connections) do
                assert(not c.ground)
                local dx, dy, dir = rotate(c.position, e.building.direction, typeobject.area)
                local x = e.building.x + dx
                local y = e.building.y + dy
                assert(FluidboxCache[pack(x, y, dir)] == nil)
                FluidboxCache[pack(x, y, dir)] = e.fluidbox.fluid
            end
        end
    end

    for e in gameplay_world.ecs:select "fluidboxes:in building:in" do
        local typeobject = iprototype.queryById(e.building.prototype)

        local inputs = typeobject.fluidboxes.input
        for i = 1, #inputs do
            local fluid = e.fluidboxes["in"..i.."_fluid"]
            for _, c in ipairs(inputs[i].connections) do
                local dx, dy, dir = rotate(c.position, e.building.direction, typeobject.area)
                local x = e.building.x + dx
                local y = e.building.y + dy
                assert(FluidboxCache[pack(x, y, dir)] == nil)
                FluidboxCache[pack(x, y, dir)] = fluid
            end
        end

        local outputs = typeobject.fluidboxes.output
        for i = 1, #outputs do
            local fluid = e.fluidboxes["out"..i.."_fluid"]
            for _, c in ipairs(outputs[i].connections) do
                local dx, dy, dir = rotate(c.position, e.building.direction, typeobject.area)
                local x = e.building.x + dx
                local y = e.building.y + dy
                assert(FluidboxCache[pack(x, y, dir)] == nil)
                FluidboxCache[pack(x, y, dir)] = fluid
            end
        end
    end
end

function fluidbox_sys:gameworld_clean()
    FluidboxCache = {}
end

function fluidbox_sys:exit()
    FluidboxCache = {}
end

local ifluidbox = ecs.interface "ifluidbox"
function ifluidbox.get(x, y, dir)
    return FluidboxCache[pack(x, y, dir)]
end