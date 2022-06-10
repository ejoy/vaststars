local ecs = ...
local world = ecs.world

local vsobject_manager = ecs.require "vsobject_manager"
local iprototype = require "gameplay.interface.prototype"
local math3d = require "math3d"
local iterrain = ecs.require "terrain"
local camera = ecs.require "engine.camera"
local get_object_id = require "global".get_object_id
local changeset = {}

local function object_newindex(self, key, value)
    self.__object[key] = value
    self.__change[key] = value
    changeset[self.__object.id] = self
end

local function new(init)
    local object = {
        id = get_object_id(),
        prototype_name = assert(init.prototype_name),
        dir = assert(init.dir),
        x = assert(init.x),
        y = assert(init.y),
        fluid_name = assert(init.fluid_name),
        fluidflow_network_id = assert(init.fluidflow_network_id),
        state = assert(init.state),
    }

    local outer = setmetatable({__object = object, __change = {}}, {__index = object, __newindex = object_newindex})
    changeset[object.id] = outer
    return outer
end

local function clone(outer)
    local object = {
        id = outer.id,
        prototype_name = assert(outer.prototype_name),
        dir = assert(outer.dir),
        x = assert(outer.x),
        y = assert(outer.y),
        fluid_name = assert(outer.fluid_name),
        fluidflow_network_id = assert(outer.fluidflow_network_id),
        state = assert(outer.state),
        gameplay_eid = outer.gameplay_eid, --TODO
        teardown = outer.teardown,
    }

    local clone = setmetatable({__object = object, __change = {}}, {__index = object, __newindex = object_newindex})
    changeset[object.id] = clone
    return clone
end

local function remove(outer)
    if not outer then
        return
    end

    assert(outer.__object.OBJECT_REMOVED == nil)
    outer.__object.OBJECT_REMOVED = true
    changeset[outer.__object.id] = outer
end

local function flush()
    local funcs = {
        prototype_name = function(outer, value)
            outer.__object.prototype_name = value
            local vsobject = assert(vsobject_manager:get(outer.id))
            vsobject:update {prototype_name = outer.prototype_name}
        end,
        dir = function(outer, value)
            outer.__object.dir = value
            local vsobject = assert(vsobject_manager:get(outer.id))
            vsobject:set_dir(value)
        end,
        state = function(outer, value)
            outer.__object.state = value
            local vsobject = assert(vsobject_manager:get(outer.id))
            vsobject:update {type = outer.state}
        end,
        x = function (outer, value)
            outer.__object._x = value
        end,
        y = function (outer, value)
            outer.__object._y = value
        end,
        fluid_name = function(outer, value)
            outer.__object.fluid_name = value
        end,
        fluidflow_network_id = function (outer, value)
            outer.__object.fluidflow_network_id = value
        end,
        gameplay_eid = function (outer, value)
            outer.__object.gameplay_eid = value
        end,
        teardown = function (outer, value)
            outer.__object.teardown = value
        end,
        REMOVED = function (outer, value)
            outer.__object.REMOVED = value
        end
    }

    local vsobject
    for object_id, outer in pairs(changeset) do
        if outer.__object.OBJECT_REMOVED then
            assert(outer.__object.REMOVED == nil)
            outer.__object.REMOVED = true
            vsobject_manager:remove(outer.id)
        else
            vsobject = vsobject_manager:get(object_id)
            if not vsobject then
                local typeobject = iprototype.queryByName("entity", outer.prototype_name)
                local position = iterrain.get_position_by_coord(outer.x, outer.y, iprototype.rotate_area(typeobject.area, outer.dir))
                assert(position)

                vsobject_manager:create {
                    id = outer.id,
                    prototype_name = outer.prototype_name,
                    dir = outer.dir,
                    position = position,
                    type = outer.state,
                }
            else
                for k, v in pairs(outer.__change) do
                    local func = assert(funcs[k])
                    func(outer, v)
                end
                if outer.__object._x or outer.__object._y then
                    outer.__object.x = outer.__object._x or outer.__object.x
                    outer.__object.y = outer.__object._y or outer.__object.y
                    local typeobject = iprototype.queryByName("entity", outer.prototype_name)
                    local position = iterrain.get_position_by_coord(outer.x, outer.y, iprototype.rotate_area(typeobject.area, outer.dir))
                    local vsobject = assert(vsobject_manager:get(outer.id))
                    vsobject:set_position(position)
                    outer.__object._x, outer.__object._y = nil, nil
                end
                outer.__change = {}
            end
        end
    end
    changeset = {}
end

local function move_delta(object, delta_vec)
    local vsobject = assert(vsobject_manager:get(object.id))
    local typeobject = iprototype.queryByName("entity", object.prototype_name)
    local position = math3d.ref(math3d.add(vsobject:get_position(), delta_vec))
    local coord = iterrain.adjust_position(math3d.tovalue(position), iprototype.rotate_area(typeobject.area, object.dir))
    if not coord then
        log.error(("can not get coord"))
        return
    end

    object.__object.x, object.__object.y = coord[1], coord[2]
    vsobject:set_position(position)
    return object
end

local function central_coord(prototype_name, dir)
    local typeobject = iprototype.queryByName("entity", prototype_name)
    local coord = iterrain.adjust_position(camera.get_central_position(), iprototype.rotate_area(typeobject.area, dir))
    if not coord then
        return
    end
    return coord[1], coord[2]
end

local function align(object)
    assert(object)
    local typeobject = iprototype.queryByName("entity", object.prototype_name)
    local coord = iterrain.adjust_position(camera.get_central_position(), iprototype.rotate_area(typeobject.area, object.dir))
    if not coord then
        return object
    end
    object.x, object.y = coord[1], coord[2]
    return object
end

local function coord(object, x, y)
    assert(object)
    assert(object.prototype_name ~= "")
    local vsobject = assert(vsobject_manager:get(object.id))
    local typeobject = iprototype.queryByName("entity", object.prototype_name)
    local position = iterrain.get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, object.dir))
    if not position then
        log.error(("can not get position"))
        return
    end
    object.x, object.y = x, y
    vsobject:set_position(position)
end

return {
    new = new,
    remove = remove,
    clone = clone,
    flush = flush,
    move_delta = move_delta,
    align = align,
    central_coord = central_coord,
    coord = coord,
}