local ecs = ...
local world = ecs.world
local w = world.w

local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local terrain = ecs.require "terrain"
local gameplay = import_package "vaststars.gameplay"
local ifluidbox = gameplay.interface "fluidbox"
local igameplay = ecs.import.interface "vaststars.gamerender|igameplay"
local iflow_connector = require "gameplay.interface.flow_connector"
local iobject = ecs.require "object"

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

local PIPE_TYPES <const> = {"pipe", "pipe_to_ground"}
local EDITOR_CACHE_NAMES = {"CONSTRUCTED"}

local function __length(t)
    local n = 0
    for _ in pairs(t) do
        n = n + 1
    end
    return n
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
    local need_build = false

    assert(e.fluidbox.fluid ~= 0)
    local fluid = e.fluidbox.fluid
    for _, connection in ipairs(typeobject.fluidbox.connections) do
        local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[e.building.direction], typeobject.area)
        local neighbor_fluid_name, neighbor_object = __find_neighbor_fluid(gameplay_world, e.building.x + x, e.building.y + y, dir, connection.ground)
        if (not neighbor_fluid_name or neighbor_fluid_name == "") and neighbor_object then
            local neighbor = assert(gameplay_world.entity[neighbor_object.gameplay_eid])
            if neighbor.fluidbox then
                print("update fluidbox", neighbor.building.x, neighbor.building.y, fluid)
                ifluidbox.update_fluidbox(neighbor, fluid)
                __update_neighbor_fluid_type(gameplay_world, neighbor, iprototype.queryById(neighbor.building.prototype))
                need_build = true
            end
        end
    end
    return need_build
end

local function __update_fluid_type(gameplay_world)
    local need_build = false

    local changed = {}
    for e in gameplay_world.ecs:select "building_changed:in building:in fluidbox:update fluidbox_changed?update eid:in" do
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
                if neighbor_fluid_name then
                    if neighbor_fluid_name ~= "" then
                        local neighbor_fluid = iprototype.queryByName(neighbor_fluid_name).id
                        fluids[neighbor_fluid] = true
                    end
                end
            end
            assert(__length(fluids) <= 1)
            if __length(fluids) == 1 then
                local fluid = next(fluids)
                ifluidbox.update_fluidbox(e, fluid)
                print("update fluidbox", e.building.x, e.building.y, fluid)
                __update_neighbor_fluid_type(gameplay_world, e, typeobject)
                need_build = true
            end
        else
            if __update_neighbor_fluid_type(gameplay_world, e, typeobject) then
                need_build = true
            end
        end
    end
    return need_build
end

local global = require "global"
local function __update_pipe_shape(gameplay_world)
    local need_build = false

    local removed = global.removed
    global.removed = {}
    -- for e in gameplay_world.ecs:select "REMOVED:in" do
    --     removed[e.eid] = true
    -- end

    for _, v in pairs(removed) do
        local typeobject = iprototype.queryById(v.prototype)
        if not typeobject.fluidbox then
            goto continue
        end
        for _, connection in ipairs(typeobject.fluidbox.connections) do
            local x, y, dir = iprototype.rotate_connection(connection.position, DIRECTION[v.direction], typeobject.area)
            local neighbor_object = __find_neighbor(v.x + x, v.y + y, dir)
            if neighbor_object and iprototype.check_types(neighbor_object.prototype_name, PIPE_TYPES) then
                neighbor_object = assert(objects:modify(neighbor_object.x, neighbor_object.y, EDITOR_CACHE_NAMES, iobject.clone))
                igameplay.remove_entity(neighbor_object.gameplay_eid, false)

                local _prototype_name, _dir = iflow_connector.set_connection(neighbor_object.prototype_name, neighbor_object.dir, iprototype.reverse_dir(dir), false)

                neighbor_object.prototype_name = _prototype_name
                neighbor_object.dir = _dir
                neighbor_object.gameplay_eid = igameplay.create_entity({
                    prototype_name = _prototype_name,
                    dir = _dir,
                    x = v.x + x,
                    y = v.y + y,
                    fluid_name = neighbor_object.fluid_name,
                })
            end
        end
        need_build = true

        ::continue::
    end

    global.removed = {}
    return need_build
end

return function(gameplay_world)
    local need_build = false
    if __update_fluid_type(gameplay_world) then
        need_build = true
    end
    if __update_pipe_shape(gameplay_world) then
        need_build = true
    end
    return need_build
end