local ecs = ...
local world = ecs.world
local w = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local FLUIDBOXES <const> = CONSTANT.FLUIDBOXES
local DIRECTION <const> = CONSTANT.DIRECTION
local PIPE_DIRECTION <const> = {
    N = DIRECTION.N,
    E = DIRECTION.E,
    S = DIRECTION.S,
    W = DIRECTION.W,
}

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
local PipeMasks = {}
local RevPipeMasks = {}

local function _length(t)
    local n = 0
    for _ in pairs(t) do
        n = n + 1
    end
    return n
end

local function _uniquekey(x, y, dir)
    return x << 16 | y << 8 | dir
end

local function _rotate(position, direction, area)
    local w, h = area >> 8, area & 0xFF
    local x, y = position[1], position[2]
    local dir = (DIRECTION[position[3]] + direction) % 4
    w = w - 1
    h = h - 1
    if direction == DIRECTION.N then
        return x, y, dir
    elseif direction == DIRECTION.E then
        return h - y, x, dir
    elseif direction == DIRECTION.S then
        return w - x, h - y, dir
    elseif direction == DIRECTION.W then
        return y, w - x, dir
    end
end

local function _check_connnection(x, y, dir, conn, e, typeobject)
    local dx, dy, ddir = iprototype.rotate_connection(conn.position, DIRECTION[e.building.direction], typeobject.area)
    return x == e.building.x + dx and y == e.building.y + dy and ddir == dir
end

local function _find_neighbor(gameplay_world, map, x, y, dir, ground)
    local succ, dx, dy = false, x, y
    for _ = 1, ground or 1 do
        succ, dx, dy = icoord.move(dx, dy, dir, 1)
        if not succ then
            return
        end

        local eid = map[icoord.pack(dx, dy)]
        if eid then
            local e = assert(gameplay_world:fetch_entity(eid))
            local typeobject = iprototype.queryById(e.building.prototype)
            if ground then
                if not typeobject.fluidbox then
                    goto continue
                end

                for _, conn in ipairs(typeobject.fluidbox.connections) do
                    if conn.ground then
                        if _check_connnection(dx, dy, iprototype.reverse_dir(dir), conn, e, typeobject) then
                            return e.eid
                        end
                    end
                end
                goto continue
            end

            if e.fluidbox then
                return e.eid

            elseif e.fluidboxes then
                for _, v in ipairs(FLUIDBOXES) do
                    if typeobject.fluidboxes[v.classify][v.index] then
                        for _, conn in ipairs(typeobject.fluidboxes[v.classify][v.index].connections) do
                            if _check_connnection(dx, dy, iprototype.reverse_dir(dir), conn, e, typeobject) then
                                return e.eid, v.fluid
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

local function _find_neighbor_fluid(...)
    local eid, fluid = _find_neighbor(...)
    if not eid then
        return
    end

    local gameplay_world = gameplay_core.get_world()
    local e = assert(gameplay_world:fetch_entity(eid))
    if e.fluidbox then
        if e.fluidbox.fluid == 0 then
            return
        end
        return e.fluidbox.fluid
    elseif e.fluidboxes then
        if e.fluidboxes[fluid] == 0 then
            return
        end
        return e.fluidboxes[fluid]
    else
        assert(false)
    end
end

local function _update_neighbor_fluid(gameplay_world, e, typeobject, map)
    assert(e.fluidbox.fluid ~= 0)
    for _, connection in ipairs(typeobject.fluidbox.connections) do
        local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)
        local eid = _find_neighbor(gameplay_world, map, e.building.x + x, e.building.y + y, dir, connection.ground)
        if eid then
            local neighbor = assert(gameplay_world:fetch_entity(eid))
            if neighbor.fluidbox and neighbor.fluidbox.fluid == 0 then
                igameplay_fluidbox.update_fluidbox(gameplay_world, neighbor, e.fluidbox.fluid)
                _update_neighbor_fluid(gameplay_world, neighbor, iprototype.queryById(neighbor.building.prototype), map)
            end
        end
    end
end

local function _check(m, d)
    return (m & (1 << (d * 2))) ~= 0
end

local function _open(m, d)
    return m | (1 << (d * 2))
end

local PileMask = 0
for _, d in pairs(PIPE_DIRECTION) do
    PileMask = _open(PileMask, d)
end

local function _update_pipe_shape(gameplay_world)
    local gameplay_ecs = gameplay_world.ecs
    local map = {}

    for e in gameplay_ecs:select "fluidbox:in building:in eid:in REMOVED:absent" do
        local typeobject = iprototype.queryById(e.building.prototype)
        if iprototype.has_type(typeobject.type, "pipe") then
            local coord = icoord.pack(e.building.x, e.building.y)
            assert(map[coord] == nil)
            map[coord] = {check = PileMask, eid = e.eid}

        elseif iprototype.has_type(typeobject.type, "pipe_to_ground") then
            local d = (DIRECTION.S + e.building.direction) % 4
            local coord = icoord.pack(e.building.x, e.building.y)
            assert(map[coord] == nil)
            map[coord] = {check = _open(0, d), eid = e.eid}
        end

        for _, connection in ipairs(typeobject.fluidbox.connections) do
            local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)
            local coord = icoord.pack(e.building.x + x, e.building.y + y)
            local m = _open(0, DIRECTION[dir])

            if not connection.ground then
                if not map[coord] then
                    map[coord] = {mask = m, check = m, eid = e.eid}
                else
                    map[coord].mask = _open(map[coord].mask or 0, DIRECTION[dir])
                    map[coord].check = _open(map[coord].check, DIRECTION[dir])
                end
            end
        end
    end

    for e in gameplay_ecs:select "fluidboxes:in building:in eid:in REMOVED:absent" do
        local typeobject = iprototype.queryById(e.building.prototype)
        for _, v in ipairs(FLUIDBOXES) do
            if typeobject.fluidboxes[v.classify][v.index] then
                for _, connection in ipairs(typeobject.fluidboxes[v.classify][v.index].connections) do
                    local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)
                    local coord = icoord.pack(e.building.x + x, e.building.y + y)
                    assert(map[coord] == nil)
                    map[coord] = {mask = _open(0, DIRECTION[dir]), check = _open(0, DIRECTION[dir]), eid = e.eid}
                end
            end
        end
    end

    local pipe = {}
    local pipe_to_ground = {}
    for e in gameplay_ecs:select "building:in fluidbox:in eid:in REMOVED:absent" do
        local typeobject = iprototype.queryById(e.building.prototype)
        local coord = icoord.pack(e.building.x, e.building.y)
        if iprototype.has_type(typeobject.type, "pipe") then
            pipe[coord] = true
        elseif iprototype.has_type(typeobject.type, "pipe_to_ground") then
            pipe_to_ground[coord] = true
        end
    end

    for coord in pairs(pipe) do
        local x, y = icoord.unpack(coord)
        local mask = 0
        for _, d in pairs(PIPE_DIRECTION) do
            local _, dx, dy = icoord.move(x, y, d, 1)
            local neighbor = map[icoord.pack(dx, dy)]
            if neighbor and _check(neighbor.check, iprototype.reverse_dir(d)) then
                mask = _open(mask, d)
            end
        end
        local v = assert(map[coord])
        if v.mask ~= mask then
            local e = assert(gameplay_world:fetch_entity(v.eid))
            local vv = assert(RevPipeMasks[iprototype.queryById(e.building.prototype).building_category][mask])
            e.building.prototype = vv.id
            e.building.direction = vv.direction
            e.building_changed = true
            v.mask = mask
        end
    end

    for coord in pairs(pipe_to_ground) do
        local x, y = icoord.unpack(coord)
        local v = assert(map[coord])
        local e = assert(gameplay_world:fetch_entity(v.eid))

        local mask = PipeMasks[e.building.prototype][e.building.direction]
        local d = (DIRECTION.S + e.building.direction) % 4
        local _, dx, dy = icoord.move(x, y, d, 1)
        local neighbor = map[icoord.pack(dx, dy)]
        if neighbor and _check(neighbor.mask, iprototype.reverse_dir(d)) then
            mask = _open(mask, d)
        end

        local v = assert(map[coord])
        if v.mask ~= mask then
            local e = assert(gameplay_world:fetch_entity(v.eid))
            local vv = assert(RevPipeMasks[iprototype.queryById(e.building.prototype).building_category][mask])
            e.building.prototype = vv.id
            e.building.direction = vv.direction
            e.building_changed = true
            v.mask = mask
        end
    end
end

local function _update_fluidbox_fluid(gameplay_world, map)
    local gameplay_ecs = gameplay_world.ecs

    local new = {}
    for e in gameplay_ecs:select "building_new:in fluidbox:in eid:in" do
        new[e.eid] = true
    end

    for eid in pairs(new) do
        local e = gameplay_world:fetch_entity(eid)
        local typeobject = iprototype.queryById(e.building.prototype)
        local fluid = e.fluidbox.fluid or 0

        if fluid == 0 then
            local fluids = {}
            for _, connection in ipairs(typeobject.fluidbox.connections) do
                local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)
                local neighbor_fluid = _find_neighbor_fluid(gameplay_world, map, e.building.x + x, e.building.y + y, dir, connection.ground)
                if neighbor_fluid then
                    fluids[neighbor_fluid] = true
                end
            end
            if _length(fluids) > 0 then
                assert(_length(fluids) == 1)
                local fluid = next(fluids)
                igameplay_fluidbox.update_fluidbox(gameplay_world, e, fluid)
                _update_neighbor_fluid(gameplay_world, e, typeobject, map)
            end
        else
            _update_neighbor_fluid(gameplay_world, e, typeobject, map)
        end
    end
end

local function _auto_set_recipe(gameplay_world, map)
    local gameplay_ecs = gameplay_world.ecs

    for e in gameplay_ecs:select "auto_set_recipe assembling:update building:in chest:update fluidboxes:update REMOVED:absent" do
        local typeobject = iprototype.queryById(e.building.prototype)
        local cache = iprototype_cache.get("recipe_config").assembling_recipes_2[typeobject.name]

        local fluids = {}
        for _, v in ipairs(FLUIDBOXES) do
            if typeobject.fluidboxes[v.classify][v.index] then
                for _, connection in ipairs(typeobject.fluidboxes[v.classify][v.index].connections) do
                    local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)
                    local neighbor_fluid = _find_neighbor_fluid(gameplay_world, map, e.building.x + x, e.building.y + y, dir, connection.ground)
                    if neighbor_fluid then
                        fluids[neighbor_fluid] = true
                    end
                end
            end
        end
        assert(_length(fluids) <= 1)
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

    for e in gameplay_ecs:select "auto_set_recipe chimney:update building:in fluidbox:update REMOVED:absent" do
        local typeobject = iprototype.queryById(e.building.prototype)
        local cache = iprototype_cache.get("recipe_config").chimney_recipes[typeobject.name]

        local fluids = {}
        for _, connection in ipairs(typeobject.fluidbox.connections) do
            local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)
            local neighbor_fluid = _find_neighbor_fluid(gameplay_world, map, e.building.x + x, e.building.y + y, dir, connection.ground)
            if neighbor_fluid then
                fluids[neighbor_fluid] = true
            end
        end
        assert(_length(fluids) <= 1)
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

local function _get_cache(gameplay_ecs)
    local map = {}

    local function cache_building(e)
        local w, h = iprototype.rotate_area(iprototype.queryById(e.building.prototype).area, e.building.direction)
        for i = 0, w - 1 do
            for j = 0, h - 1 do
                local coord = icoord.pack(e.building.x + i, e.building.y + j)
                assert(map[coord] == nil)
                map[coord] = e.eid
            end
        end
    end

    for e in gameplay_ecs:select "fluidbox:in building:in eid:in REMOVED:absent" do
        cache_building(e)
    end

    for e in gameplay_ecs:select "fluidboxes:in building:in eid:in REMOVED:absent" do
        cache_building(e)
    end

    return map
end

local function _calc_pipe_mask(pt, direction)
    local mask = 0
    for _, c in ipairs(pt.fluidbox.connections) do
        local dir = (DIRECTION[c.position[3]] + direction) % 4
        mask = mask | ((c.ground and 2 or 1) << (dir * 2))
    end
    return mask
end

function fluidbox_sys:prototype_restore()
    for _, pt in pairs(iprototype.each_type("building")) do
        if not iprototype.has_types(pt.type, "pipe", "pipe_to_ground") then
            goto continue
        end
        for _, dir in pairs(pt.building_direction) do
            local mask = _calc_pipe_mask(pt, DIRECTION[dir])

            PipeMasks[pt.id] = PipeMasks[pt.id] or {}
            assert(PipeMasks[pt.id][DIRECTION[dir]] == nil)
            PipeMasks[pt.id][DIRECTION[dir]] = mask

            RevPipeMasks[pt.building_category] = RevPipeMasks[pt.building_category] or {}
            assert(RevPipeMasks[pt.building_category][mask] == nil)
            RevPipeMasks[pt.building_category][mask] = {id = pt.id, direction = DIRECTION[dir]}
        end
        ::continue::
    end
end

function fluidbox_sys:gameworld_prebuild()
    local gameplay_world = gameplay_core.get_world()
    local gameplay_ecs = gameplay_world.ecs

    _update_pipe_shape(gameplay_world)

    local map = _get_cache(gameplay_ecs)
    _update_fluidbox_fluid(gameplay_world, map)
    _auto_set_recipe(gameplay_world, map)
end

function fluidbox_sys:gameworld_build()
    local gameplay_world = gameplay_core.get_world()
    local gameplay_ecs = gameplay_world.ecs

    FluidboxCache = {}

    for e in gameplay_ecs:select "fluidbox:in building:in" do
        local typeobject = iprototype.queryById(e.building.prototype)
        if iprototype.has_type(typeobject.type, "pipe") then
            for _, dir in pairs(PIPE_DIRECTION) do
                assert(FluidboxCache[_uniquekey(e.building.x, e.building.y, dir)] == nil)
                FluidboxCache[_uniquekey(e.building.x, e.building.y, dir)] = e.fluidbox.fluid
            end
        elseif iprototype.has_type(typeobject.type, "pipe_to_ground") then
            local dir = (DIRECTION.S + e.building.direction) % 4
            assert(FluidboxCache[_uniquekey(e.building.x, e.building.y, dir)] == nil)
            FluidboxCache[_uniquekey(e.building.x, e.building.y, dir)] = e.fluidbox.fluid
        else
            for _, c in ipairs(typeobject.fluidbox.connections) do
                assert(not c.ground)
                local dx, dy, dir = _rotate(c.position, e.building.direction, typeobject.area)
                local x = e.building.x + dx
                local y = e.building.y + dy
                assert(FluidboxCache[_uniquekey(x, y, dir)] == nil)
                FluidboxCache[_uniquekey(x, y, dir)] = e.fluidbox.fluid
            end
        end
    end

    for e in gameplay_ecs:select "fluidboxes:in building:in" do
        local typeobject = iprototype.queryById(e.building.prototype)

        local inputs = typeobject.fluidboxes.input
        for i = 1, #inputs do
            local fluid = e.fluidboxes["in"..i.."_fluid"]
            for _, c in ipairs(inputs[i].connections) do
                local dx, dy, dir = _rotate(c.position, e.building.direction, typeobject.area)
                local x = e.building.x + dx
                local y = e.building.y + dy
                assert(FluidboxCache[_uniquekey(x, y, dir)] == nil)
                FluidboxCache[_uniquekey(x, y, dir)] = fluid
            end
        end

        local outputs = typeobject.fluidboxes.output
        for i = 1, #outputs do
            local fluid = e.fluidboxes["out"..i.."_fluid"]
            for _, c in ipairs(outputs[i].connections) do
                local dx, dy, dir = _rotate(c.position, e.building.direction, typeobject.area)
                local x = e.building.x + dx
                local y = e.building.y + dy
                assert(FluidboxCache[_uniquekey(x, y, dir)] == nil)
                FluidboxCache[_uniquekey(x, y, dir)] = fluid
            end
        end
    end

    gameplay_ecs:clear("building_new")
end

function fluidbox_sys:exit()
    FluidboxCache = {}
    PipeMasks = {}
    RevPipeMasks = {}
end

local ifluidbox = {}
function ifluidbox.get(x, y, dir)
    return FluidboxCache[_uniquekey(x, y, DIRECTION[dir])]
end

ifluidbox.rotate = _rotate

return ifluidbox
