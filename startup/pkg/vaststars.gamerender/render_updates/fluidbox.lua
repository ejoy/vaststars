local ecs = ...
local world = ecs.world
local w = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local FLUIDBOXES <const> = CONSTANT.FLUIDBOXES
local DIRECTION <const> = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
    [0] = 0,
    [1] = 1,
    [2] = 2,
    [3] = 3,
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

local iprototype = require "gameplay.interface.prototype"
local icoord = require "coord"
local gameplay_core = require "gameplay.core"
local fluidbox_sys = ecs.system "fluidbox_system"
local gameplay = import_package "vaststars.gameplay"
local igameplay_fluidbox = gameplay.interface "fluidbox"
local iprototype_cache = require "gameplay.prototype_cache.init"
local iworld = require "gameplay.interface.world"
local igameplay_chimney = gameplay.interface "chimney"

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

local function _check_connnection(x, y, dir, conn, e, typeobject)
    local dx, dy, ddir = iprototype.rotate_connection(conn.position, DIRECTION[e.building.direction], typeobject.area)
    return x == e.building.x + dx and y == e.building.y + dy and ddir == dir
end

local function _find_neighbor(gameplay_world, map, x, y, dir, ground)
    local succ, dx, dy = false, x, y
    for i = 1, ground or 1 do
        succ, dx, dy = icoord.move(dx, dy, dir, 1)
        if not succ then
            return
        end

        local eid = map[iprototype.packcoord(dx, dy)]
        if eid then
            local e = assert(gameplay_world.entity[eid])
            local typeobject = iprototype.queryById(e.building.prototype)
            if ground then
                if not typeobject.fluidbox then
                    goto continue
                end

                for _, conn in ipairs(typeobject.fluidbox.connections) do
                    if conn.ground then
                        if _check_connnection(dx, dy, iprototype.reverse_dir(dir), conn, e, typeobject) then
                            if e.fluidbox.fluid == 0 then
                                return
                            end
                            return e.fluidbox.fluid, e.eid
                        end
                    end
                end
                return
            end

            if e.fluidbox then
                if e.fluidbox.fluid == 0 then
                    return
                end
                return e.fluidbox.fluid, e.eid

            elseif e.fluidboxes then
                for _, v in ipairs(FLUIDBOXES) do
                    if typeobject.fluidboxes[v.classify][v.index] then
                        for _, conn in ipairs(typeobject.fluidboxes[v.classify][v.index].connections) do
                            if _check_connnection(dx, dy, iprototype.reverse_dir(dir), conn, e, typeobject) then
                                local f = e.fluidboxes[v.fluid]
                                if f == 0 then
                                    return
                                end
                                return f, e.eid
                            end
                        end
                    end
                end
                return
            end
            goto continue
        end
        ::continue::
    end
end

local function _update_neighbor_fluid(gameplay_world, e, typeobject, map)
    assert(e.fluidbox.fluid ~= 0)
    for _, connection in ipairs(typeobject.fluidbox.connections) do
        local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)
        local fluid, eid = _find_neighbor(gameplay_world, map, e.building.x + x, e.building.y + y, dir, connection.ground)
        if fluid then
            local neighbor = assert(gameplay_world.entity[eid])
            if neighbor.fluidbox and (neighbor.fluidbox.fluid or 0) == 0 then
                print("update fluidbox", neighbor.building.x, neighbor.building.y, fluid)
                igameplay_fluidbox.update_fluidbox(gameplay_world, neighbor, fluid)
                _update_neighbor_fluid(gameplay_world, neighbor, iprototype.queryById(neighbor.building.prototype), map)
            end
        end
    end
end

function fluidbox_sys:gameworld_prebuild()
    local gameplay_world = gameplay_core.get_world()
    local gameplay_ecs = gameplay_world.ecs

    local map = {}
    local function cache_building(e)
        local w, h = iprototype.rotate_area(iprototype.queryById(e.building.prototype).area, e.building.direction)
        for i = 0, w - 1 do
            for j = 0, h - 1 do
                local coord = iprototype.packcoord(e.building.x + i, e.building.y + j)
                -- assert(map[coord] == nil)
                map[coord] = e.eid
            end
        end
    end

    for e in gameplay_ecs:select "fluidbox:in building:in eid:in" do
        cache_building(e)
    end

    for e in gameplay_ecs:select "fluidboxes:in building:in eid:in" do
        cache_building(e)
    end

    -----
    local new = {}
    for e in gameplay_ecs:select "building_new:in fluidbox:in eid:in" do
        new[e.eid] = true
    end

    for eid in pairs(new) do
        local e = gameplay_world.entity[eid]
        local typeobject = iprototype.queryById(e.building.prototype)
        local fluid = e.fluidbox.fluid or 0

        if fluid == 0 then
            local fluids = {}
            for _, connection in ipairs(typeobject.fluidbox.connections) do
                local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)
                local neighbor_fluid = _find_neighbor(gameplay_world, map, e.building.x + x, e.building.y + y, dir, connection.ground)
                print(e.building.x + x, e.building.y + y, neighbor_fluid)
                if neighbor_fluid then
                    fluids[neighbor_fluid] = true
                end
            end
            if length(fluids) > 0 then
                assert(length(fluids) == 1)
                local fluid = next(fluids)
                igameplay_fluidbox.update_fluidbox(gameplay_world, e, fluid)
                print("update fluidbox", e.building.x, e.building.y, fluid)
                _update_neighbor_fluid(gameplay_world, e, typeobject, map)
            end
        else
            _update_neighbor_fluid(gameplay_world, e, typeobject, map)
        end
    end

    -- 
    for e in gameplay_world.ecs:select "auto_set_recipe:in assembling:update building:in chest:update fluidboxes:update REMOVED:absent" do
        local typeobject = iprototype.queryById(e.building.prototype)
        local cache = iprototype_cache.get("recipe_config").assembling_recipes_2[typeobject.name]

        local fluids = {}
        for _, v in ipairs(FLUIDBOXES) do
            if typeobject.fluidboxes[v.classify][v.index] then
                for _, connection in ipairs(typeobject.fluidboxes[v.classify][v.index].connections) do
                    local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)
                    local neighbor_fluid = _find_neighbor(gameplay_world, map, e.building.x + x, e.building.y + y, dir, connection.ground)
                    print(e.building.x + x, e.building.y + y, neighbor_fluid)
                    if neighbor_fluid then
                        fluids[neighbor_fluid] = true
                    end
                end
            end
        end
        assert(length(fluids) <= 1)
        local fluid = next(fluids)
        if fluid then
            local recipe_name = cache[iprototype.queryById(fluid).name]
            if recipe_name then
                local pt = iprototype.queryByName(recipe_name)
                if pt.id ~= e.assembling.recipe then
                    iworld.set_recipe(gameplay_core.get_world(), e, recipe_name, typeobject.recipe_init_limit)
                end
            end
        end
    end

    for e in gameplay_world.ecs:select "auto_set_recipe:in chimney:update building:in fluidbox:update REMOVED:absent" do
        local typeobject = iprototype.queryById(e.building.prototype)
        local cache = iprototype_cache.get("recipe_config").chimney_recipes[typeobject.name]

        local fluids = {}
        for _, connection in ipairs(typeobject.fluidbox.connections) do
            local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)
            local neighbor_fluid = _find_neighbor(gameplay_world, map, e.building.x + x, e.building.y + y, dir, connection.ground)
            print(e.building.x + x, e.building.y + y, neighbor_fluid)
            if neighbor_fluid then
                fluids[neighbor_fluid] = true
            end
        end
        assert(length(fluids) <= 1)
        local fluid = next(fluids)
        if fluid then
            local recipe_name = cache[iprototype.queryById(fluid).name]
            if recipe_name then
                local pt_recipe = iprototype.queryByName(recipe_name)
                if pt_recipe.id ~= e.chimney.recipe then
                    igameplay_chimney.set_recipe(e, recipe_name)
                end

                if fluid ~= e.fluidbox.fluid then
                    igameplay_fluidbox.update_fluidbox(gameplay_world, e, fluid)
                end
            end
        end
    end
end

function fluidbox_sys:gameworld_build()
    local gameplay_world = gameplay_core.get_world()
    local gameplay_ecs = gameplay_world.ecs

    FluidboxCache = {}

    for e in gameplay_ecs:select "fluidbox:in building:in" do
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

    for e in gameplay_ecs:select "fluidboxes:in building:in" do
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

    gameplay_ecs:clear("building_new")
end

function fluidbox_sys:gameworld_clean()
    FluidboxCache = {}
end

function fluidbox_sys:exit()
    FluidboxCache = {}
end

local ifluidbox = {}
function ifluidbox.get(x, y, dir)
    return FluidboxCache[pack(x, y, DIRECTION[dir])]
end

ifluidbox.rotate = rotate

return ifluidbox
