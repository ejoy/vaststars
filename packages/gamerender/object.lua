local ecs = ...
local world = ecs.world

local vsobject_manager = ecs.require "vsobject_manager"
local iprototype = require "gameplay.interface.prototype"
local math3d = require "math3d"
local terrain = ecs.require "terrain"
local DEFAULT_DIR <const> = 'N'
local camera = ecs.require "engine.camera"

local function new(typeobject, x, y, dir, state)
    dir = dir or DEFAULT_DIR
    state = state or "construct"

    local position
    if not x and not y then
        local coord
        coord, position = terrain.adjust_position(camera.get_central_position(), iprototype:rotate_area(typeobject.area, dir))
        x = x or coord[1]
        y = y or coord[2]
    else
        position = terrain.get_position_by_coord(x, y, iprototype:rotate_area(typeobject.area, dir))
    end

    local object = {
        id = 0,
        gameplay_eid = 0,
        prototype_name = typeobject.name,
        dir = DEFAULT_DIR,
        x = x,
        y = y,
        teardown = false,
        headquater = typeobject.headquater or false,
        fluid_name = "",
        fluidflow_network_id = 0,
        state = state,
    }

    local vsobject = vsobject_manager:create {
        prototype_name = object.prototype_name,
        dir = object.dir,
        position = position,
        type = object.state,
    }

    object.id = vsobject.id

    return object
end

local function remove(object)
    vsobject_manager:remove(object.id)
end

local function move(object, delta_vec)
    assert(object)
    assert(object.prototype_name ~= "")
    local vsobject = assert(vsobject_manager:get(object.id))
    local typeobject = iprototype:queryByName("entity", object.prototype_name)
    local position = math3d.ref(math3d.add(vsobject:get_position(), delta_vec))
    local coord = terrain.adjust_position(math3d.tovalue(position), iprototype:rotate_area(typeobject.area, object.dir))
    if not coord then
        log.error(("can not get coord"))
        return
    end

    object.x, object.y = coord[1], coord[2]
    vsobject:set_position(position)
    return object
end

local function adjust(object)
    assert(object)
    local coord, position = terrain.adjust_position(camera.get_central_position(), 1, 1) -- 1, 1 水管 / 路块的 width & height
    if not coord then
        return
    end
    local vsobject = assert(vsobject_manager:get(object.id))
    vsobject:set_position(position)
    object.x, object.y = coord[1], coord[2]
    return object
end

local function state_update(object)
    local vsobject = assert(vsobject_manager:get(object.id))
    vsobject:update {type = object.state}
end

return {
    new = new,
    remove = remove,
    move = move,
    adjust = adjust,
    state_update = state_update,
}