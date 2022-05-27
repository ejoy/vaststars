local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local create_builder = ecs.require "editor.builder"
local vsobject_manager = ecs.require "vsobject_manager"
local DEFAULT_DIR <const> = 'N'
local terrain = ecs.require "terrain"
local camera = ecs.require "engine.camera"
local ifluid = require "gameplay.interface.fluid"
local math3d = require "math3d"
local math_abs = math.abs
local global = require "global"
local objects = global.objects
local tile_objects = global.tile_objects
local ieditor = ecs.require "editor.editor"
local ALL_CACHE <const> = global.cache_names
local get_fluidboxes = require "gameplay.utility.get_fluidboxes"
local gameplay_core = require "gameplay.core"
local ALL_DIR <const> = require("gameplay.interface.constant").ALL_DIR
local flow_shape = require "gameplay.utility.flow_shape"

local function get_object(x, y)
    local tile_object = tile_objects:get(ALL_CACHE, iprototype:packcoord(x, y))
    if not tile_object then
        return
    end

    return assert(objects:get(ALL_CACHE, tile_object.id))
end

local get_valid_fluidbox ; do
    local PIPE_FLUIDBOXES_DIR = ALL_DIR

    local funcs = {}
    funcs["fluidbox"] = function(typeobject, x, y, dir, result, fluid_name, pipe_network_id)
        for _, conn in ipairs(typeobject.fluidbox.connections) do
            local dx, dy, dir = iprototype:rotate_fluidbox(conn.position, dir, typeobject.area)
            result[#result+1] = {x = x + dx, y = y + dy, dir = dir, fluid_name = fluid_name, pipe_network_id = pipe_network_id}
        end
        return result
    end

    local function get_fluidboxes_fluid_name(fluid_name, iotype, index)
        if not fluid_name[iotype] then
            return ""
        end
        return fluid_name[iotype][index] or ""
    end

    local iotypes <const> = {"input", "output"}
    funcs["fluidboxes"] = function(typeobject, x, y, dir, result, fluid_name, pipe_network_id)
        for _, iotype in ipairs(iotypes) do
            for _, v in ipairs(typeobject.fluidboxes[iotype]) do
                for index, conn in ipairs(v.connections) do
                        local dx, dy, dir = iprototype:rotate_fluidbox(conn.position, dir, typeobject.area)
                        result[#result+1] = {x = x + dx, y = y + dy, dir = dir, fluid_name = get_fluidboxes_fluid_name(fluid_name, iotype, index)}
                end
            end
        end
        return result
    end

    function get_valid_fluidbox(prototype_name, x, y, dir, fluid_name, pipe_network_id)
        local r = {}
        local typeobject = assert(iprototype:queryByName("entity", prototype_name))
        if typeobject.pipe then
            for _, dir in ipairs(PIPE_FLUIDBOXES_DIR) do
                r[#r+1] = {x = x, y = y, dir = dir, fluid_name = fluid_name}
            end
        else
            local types = typeobject.type
            for i = 1, #types do
                local func = funcs[types[i]]
                if func then
                    func(typeobject, x, y, dir, r, fluid_name, pipe_network_id)
                end
            end
        end
        return r
    end
end

local function set_object_appearance(object, vsobject_type)
    local vsobject = assert(vsobject_manager:get(object.id))
    vsobject:update {type = vsobject_type}
end

local function get_distance(x1, y1, x2, y2)
    return (x1 - x2) ^ 2 + (y1 - y2) ^ 2
end

local function calc_dir(x1, y1, x2, y2)
    local dx = math_abs(x1 - x2)
    local dy = math_abs(y1 - y2)
    if dx > dy then
        if x1 < x2 then
            return "E"
        else
            return "W"
        end
    else
        if y1 < y2 then
            return "S"
        else
            return "N"
        end
    end
end

local function get_starting_fluidbox_coord(starting_x, starting_y, x, y)
    local object = get_object(starting_x, starting_y)
    if not object then
        return starting_x, starting_y, "", 0, calc_dir(starting_x, starting_y, x, y)
    end

    local typeobject = iprototype:queryByName("entity", object.prototype_name)
    if typeobject.pipe then
        return starting_x, starting_y, object.fluid_name, object.pipe_network_id, calc_dir(starting_x, starting_y, x, y)
    end

    local r
    for _, v in ipairs(get_valid_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name, object.pipe_network_id)) do
        r = r or v
        if get_distance(r.x, r.y, x, y) > get_distance(v.x, v.y, x, y) then
            r = v
        end
    end

    assert(r)
    assert(object.pipe_network_id) -- TODO
    return r.x, r.y, r.fluid_name, object.pipe_network_id, r.dir
end

local dir_vector = {
    N = {x = 0,  y = -1},
    S = {x = 0,  y = 1},
    W = {x = -1, y = 0},
    E = {x = 1,  y = 0},
}

local function get_ending_fluidbox_coord(starting_x, starting_y, starting_fluid_name, starting_pipe_network_id, starting_dir, x, y)
    local dx = math_abs(starting_x - x)
    local dy = math_abs(starting_y - y)
    x, y = ieditor:get_dir_coord(starting_x, starting_y, starting_dir, dx, dy)

    local object = get_object(x, y)
    if not object then
        return true, x, y, starting_fluid_name, starting_pipe_network_id
    end

    local r
    for _, v in ipairs(get_valid_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name, object.pipe_network_id)) do
        local dx = math_abs(starting_x - v.x)
        local dy = math_abs(starting_y - v.y)
        local vec = assert(dir_vector[v.dir])
        if starting_x == v.x + vec.x * dx and starting_y == v.y + vec.y * dy then
            r = v
        end
    end

    if not r then
        assert(object.fluid_name and object.pipe_network_id) -- TODO
        return false, x, y, object.fluid_name, object.pipe_network_id
    end

    assert(starting_fluid_name)
    if starting_fluid_name ~= "" and r.fluid_name ~= "" and r.fluid_name ~= starting_fluid_name then
        return false, x, y, object.fluid_name, object.pipe_network_id
    end

    return true, r.x, r.y, object.fluid_name, object.pipe_network_id
end

local function show_starting_indicator(starting_x, starting_y, starting_fluid_name, starting_pipe_network_id, starting_dir, prototype_name, x, y)
    ieditor:revert_changes({"INDICATOR"})

    local object = get_object(x, y)
    if not object then
        return
    end
    ieditor:set_object(object, "INDICATOR")

    local typeobject = iprototype:queryByName("entity", object.prototype_name)
    local coord_indicator_typeobject = iprototype:queryByName("entity", prototype_name)

    for _, v in ipairs(get_fluidboxes(object.prototype_name, object.x, object.y, object.dir)) do
        for dir in pairs(v.fluidbox_dir) do
            local px, py = ieditor:get_dir_coord(v.x, v.y, dir)
            if get_ending_fluidbox_coord(starting_x, starting_y, starting_fluid_name, starting_pipe_network_id, starting_dir, px, py) then
                local position = terrain.get_position_by_coord(px, py, iprototype:rotate_area(coord_indicator_typeobject.area, dir))

                local vsobject = vsobject_manager:create {
                    prototype_name = flow_shape:get_init_prototype_name(prototype_name),
                    dir = dir,
                    position = position,
                    type = "indicator",
                }

                local indicator_object = {
                    id = vsobject.id,
                    gameplay_eid = 0,
                    prototype_name = flow_shape:get_init_prototype_name(prototype_name),
                    dir = dir,
                    x = px,
                    y = py,
                    teardown = false,
                    headquater = typeobject.headquater or false,
                    fluid_name = "",
                    pipe_network_id = 0,
                }

                ieditor:set_object(indicator_object, "INDICATOR")
                ieditor:refresh_flow_shape({"INDICATOR"}, "INDICATOR", indicator_object, iprototype:opposite_dir(dir))
            end
        end
    end
end

local function is_valid_starting(x, y)
    local object = get_object(x, y)
    if not object then
        return true
    end

    local t = get_valid_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name, object.pipe_network_id)
    return #t > 0
end

local function prepare_starting(self, datamodel)
    local coord_indicator = self.coord_indicator

    if is_valid_starting(coord_indicator.x, coord_indicator.y) then
        datamodel.show_batch_mode_begin = true
        set_object_appearance(coord_indicator, "construct")
    else
        datamodel.show_batch_mode_begin = false
        set_object_appearance(coord_indicator, "invalid_construct")
    end

    --
    local object = get_object(coord_indicator.x, coord_indicator.y)
    if object then
        local starting_fluidbox_x, starting_fluidbox_y, starting_fluid_name, starting_pipe_network_id, starting_dir = get_starting_fluidbox_coord(coord_indicator.x, coord_indicator.y, coord_indicator.x, coord_indicator.y)
        show_starting_indicator(starting_fluidbox_x, starting_fluidbox_y, starting_fluid_name, starting_pipe_network_id, starting_dir, self.prototype_name, object.x, object.y)
    end
end

-- FLUIDTODO
local function show_pipe_indicator(cache_name, prototype_name, starting_x, starting_y, starting_dir, ending_x, ending_y, vsobject_type, fluid_name, pipe_network_id)
    local step_x
    if starting_x > ending_x then
        step_x = -1
    else
        step_x = 1
    end

    local step_y
    if starting_y > ending_y then
        step_y = -1
    else
        step_y = 1
    end

    local refresh = false -- todo
    local typeobject = iprototype:queryByName("entity", prototype_name)
    for x = starting_x, ending_x, step_x do -- todo
        for y = starting_y, ending_y, step_y do
            local object = get_object(x, y)
            if not object then
                local position = terrain.get_position_by_coord(x, y, iprototype:rotate_area(typeobject.area, DEFAULT_DIR))

                local vsobject = vsobject_manager:create {
                    prototype_name = flow_shape:get_init_prototype_name(prototype_name),
                    dir = DEFAULT_DIR,
                    position = position,
                    type = vsobject_type,
                }

                object = {
                    id = vsobject.id,
                    gameplay_eid = 0,
                    prototype_name = flow_shape:get_init_prototype_name(prototype_name),
                    dir = DEFAULT_DIR,
                    x = x,
                    y = y,
                    teardown = false,
                    headquater = typeobject.headquater or false,
                    fluid_name = fluid_name,
                    pipe_network_id = pipe_network_id,
                }
            else
                for _, object in objects:selectall(ALL_CACHE, "pipe_network_id", object.pipe_network_id) do
                    local o = ieditor:clone_object(object)
                    o.pipe_network_id = pipe_network_id
                    o.fluid_name = fluid_name
                    ieditor:set_object(o, "TEMPORARY")
                end
            end
            ieditor:set_object(object, cache_name)

            if refresh then
                ieditor:refresh_flow_shape(ALL_CACHE, "TEMPORARY", object, iprototype:opposite_dir(starting_dir))
            end
            refresh = true
        end
    end
end

-- TODO
local function has_object(starting_coord_x, starting_coord_y, cur_x, cur_y)
    local dx = math_abs(starting_coord_x - cur_x)
    local dy = math_abs(starting_coord_y - cur_y)
    local step

    local find_id = {}
    local starting_object = get_object(starting_coord_x, starting_coord_y)
    if starting_object then
        find_id[starting_object.id] = true
    end
    local ending_object = get_object(cur_x, cur_y)
    if ending_object then
        find_id[ending_object.id] = true
    end

    if dx >= dy then
        if starting_coord_x <= cur_x then
            step = 1
        else
            step = -1
        end

        for vx = starting_coord_x + step, cur_x, step do
            local object = get_object(vx, starting_coord_y)
            if object and not find_id[object.id] then
                local typeobject = iprototype:queryByName("entity", object.prototype_name)
                if not typeobject.pipe then
                    return true
                end
            end
        end
        return false
    else
        if starting_coord_y <= cur_y then
            step = 1
        else
            step = -1
        end

        for vy = starting_coord_y, cur_y, step do
            local object = get_object(starting_coord_x, vy)
            local is_pipe
            if object then
                local typeobject = iprototype:queryByName("entity", object.prototype_name)
                is_pipe = typeobject.pipe
            end
            if object and not find_id[object.id] and not is_pipe then
                return true
            end
        end
        return false
    end
end

-- TODO
local function is_pipe(object)
    if not object then
        return true
    end

    local typeobject = iprototype:queryByName("entity", object.prototype_name)
    return typeobject.pipe
end

local function start(self, datamodel)
    local coord_indicator = self.coord_indicator
    local starting_fluidbox_x, starting_fluidbox_y, starting_fluid_name, starting_pipe_network_id, starting_dir = get_starting_fluidbox_coord(self.starting_coord.x, self.starting_coord.y, coord_indicator.x, coord_indicator.y)
    local success, ending_fluidbox_x, ending_fluidbox_y, ending_fluid_name, ending_pipe_network_id = get_ending_fluidbox_coord(starting_fluidbox_x, starting_fluidbox_y, starting_fluid_name, starting_pipe_network_id, starting_dir, coord_indicator.x, coord_indicator.y)
    if not success then
        datamodel.show_confirm = false
        show_pipe_indicator("INDICATOR", coord_indicator.prototype_name, starting_fluidbox_x, starting_fluidbox_y, starting_dir, ending_fluidbox_x, ending_fluidbox_y, "invalid_construct", "", 0)
        return
    end

    if has_object(starting_fluidbox_x, starting_fluidbox_y, ending_fluidbox_x, ending_fluidbox_y) then
        datamodel.show_confirm = false
        show_pipe_indicator("INDICATOR", coord_indicator.prototype_name, starting_fluidbox_x, starting_fluidbox_y, starting_dir, ending_fluidbox_x, ending_fluidbox_y, "invalid_construct", "", 0)
        return
    end

    local starting_object = get_object(starting_fluidbox_x, starting_fluidbox_y)
    local ending_object = get_object(ending_fluidbox_x, ending_fluidbox_y)

    -- the case where there is no building at one of the starting and ending points
    if not starting_object or not ending_object then
        datamodel.show_confirm = true
        local object = starting_object or ending_object
        local fluid_name, pipe_network_id
        if object then
            fluid_name = object.fluid_name
            pipe_network_id = object.pipe_network_id
        else
            global.pipe_network_id = global.pipe_network_id + 1
            fluid_name = ""
            pipe_network_id = global.pipe_network_id
        end
        show_pipe_indicator("TEMPORARY", coord_indicator.prototype_name, starting_fluidbox_x, starting_fluidbox_y, starting_dir, ending_fluidbox_x, ending_fluidbox_y, "construct", fluid_name, pipe_network_id)
        return
    end

    if starting_object.id == ending_object.id then
        datamodel.show_confirm = false
        show_pipe_indicator("INDICATOR", coord_indicator.prototype_name, starting_fluidbox_x, starting_fluidbox_y, starting_dir, ending_fluidbox_x, ending_fluidbox_y, "invalid_construct", "", 0)
        return
    end

    -- the start point and end point are not pipes and adjacent buildings
    if not is_pipe(starting_object) and not is_pipe(ending_object) then
        for _, dir in ipairs(ALL_DIR) do
            local x, y = ieditor:get_dir_coord(starting_fluidbox_x, starting_fluidbox_y, dir)
            if x == ending_fluidbox_x and y == ending_fluidbox_y then
                datamodel.show_confirm = false
                show_pipe_indicator("INDICATOR", coord_indicator.prototype_name, starting_fluidbox_x, starting_fluidbox_y, starting_dir, ending_fluidbox_x, ending_fluidbox_y, "invalid_construct", "", 0)
                return
            end
        end
    end

    datamodel.show_confirm = true

    local fluid_name, pipe_network_id
    if starting_pipe_network_id ~= 0 or ending_pipe_network_id ~= 0 then
        local objecta, objectb
        if starting_pipe_network_id == 0 then
            objecta, objectb = starting_object, ending_object
        else
            objecta, objectb = ending_object, starting_object
        end
        local typeobject = iprototype:queryByName("entity", objecta.prototype_name)
        if iprototype:has_type(typeobject.type, "fluidbox") then
            for _, object in objects:selectall(ALL_CACHE, "pipe_network_id", objectb.pipe_network_id) do
                local o = ieditor:clone_object(object)
                o.pipe_network_id = objecta.pipe_network_id
                o.fluid_name = objecta.fluid_name
                ieditor:set_object(o, "TEMPORARY")
            end
        else
            assert(iprototype:has_type(typeobject.type, "fluidboxes"))
        end
        fluid_name, pipe_network_id = objecta.fluid_name, objecta.pipe_network_id
    else
        fluid_name, pipe_network_id = starting_fluid_name, 0
    end

    show_pipe_indicator("TEMPORARY", coord_indicator.prototype_name, starting_fluidbox_x, starting_fluidbox_y, starting_dir, ending_fluidbox_x, ending_fluidbox_y, "construct", fluid_name, pipe_network_id)
end

--------------------------------------------------------------------------------------------------

local function __new_entity(typeobject, dir, x, y, position, vsobject_type)
    local vsobject = vsobject_manager:create {
        prototype_name = typeobject.name,
        dir = dir,
        position = position,
        type = vsobject_type,
    }
    local object = {
        id = vsobject.id,
        gameplay_eid = 0,
        prototype_name = typeobject.name,
        dir = dir,
        x = x,
        y = y,
        teardown = false,
        headquater = typeobject.headquater or false,
        fluid_name = "",
        pipe_network_id = 0,
    }

    return object
end

--
local function new_entity(self, datamodel, typeobject)
    if self.coord_indicator then
        vsobject_manager:remove(self.coord_indicator.id)
    end

    local dir = DEFAULT_DIR
    local coord, position = terrain.adjust_position(camera.get_central_position(), iprototype:rotate_area(typeobject.area, dir))
    local x, y = coord[1], coord[2]
    self.prototype_name = typeobject.name
    self.coord_indicator = __new_entity(typeobject, dir, x, y, position, "construct")

    --
    prepare_starting(self, datamodel)
end

local function touch_move(self, datamodel, delta_vec)
    assert(self.coord_indicator)
    assert(self.prototype_name ~= "")
    local vsobject = assert(vsobject_manager:get(self.coord_indicator.id))
    local typeobject = iprototype:queryByName("entity", self.prototype_name)
    local position = math3d.ref(math3d.add(vsobject:get_position(), delta_vec))
    local coord = terrain.adjust_position(math3d.tovalue(position), iprototype:rotate_area(typeobject.area, self.coord_indicator.dir))
    if not coord then
        log.error(("can not get coord"))
        return
    end
    self.coord_indicator.x, self.coord_indicator.y = coord[1], coord[2]
    vsobject:set_position(position)

    -- TODO
    local coord_indicator = assert(self.coord_indicator)
    if coord[1] == coord_indicator.x and coord[2] == coord_indicator.y then
        return
    end

    local vsobject = assert(vsobject_manager:get(coord_indicator.id))
    vsobject:set_position(position)
    coord_indicator.x, coord_indicator.y = coord[1], coord[2]

    --
    ieditor:revert_changes({"INDICATOR", "TEMPORARY"})

    if not self.starting_coord then
        prepare_starting(self, datamodel)
        return
    end

    start(self, datamodel)
end

local function touch_end(self, datamodel)
    
    local coord_indicator = assert(self.coord_indicator)
    local coord, position = terrain.adjust_position(camera.get_central_position(), 1, 1) -- 1, 1 水管 / 路块的 width & height
    if not coord then
        return
    end
    local vsobject = assert(vsobject_manager:get(coord_indicator.id))
    vsobject:set_position(position)
    coord_indicator.x, coord_indicator.y = coord[1], coord[2]

    --
    ieditor:revert_changes({"INDICATOR", "TEMPORARY"})

    if not self.starting_coord then
        prepare_starting(self, datamodel)
        return
    end

    start(self, datamodel)
end

local function confirm(self, datamodel)
    for _, object in objects:all("TEMPORARY") do
        local vsobject = assert(vsobject_manager:get(object.id))
        vsobject:update {type = "confirm"}
    end
    objects:commit("TEMPORARY", "CONFIRM")
    tile_objects:commit("TEMPORARY", "CONFIRM")

    local typeobject = iprototype:queryByName("entity", self.prototype_name)
    self:new_entity(datamodel, typeobject)

    self.starting_coord = nil
    datamodel.show_confirm = false
    datamodel.show_construct_complete = true
end

local gameplay = import_package "vaststars.gameplay"
local ifluidbox = gameplay.interface "fluidbox"

local function complete(self, datamodel)
    vsobject_manager:remove(self.coord_indicator.id)
    self.coord_indicator = nil

    self:revert_changes({"INDICATOR", "TEMPORARY"})

    datamodel.show_rotate = false
    datamodel.show_confirm = false

    local needbuild = false
    for _, object in objects:all("CONFIRM") do
        object.vsobject_type = "constructed"

        local vsobject = assert(vsobject_manager:get(object.id))
        vsobject:update {type = "constructed"}

        if object.gameplay_eid == 0 then
            object.gameplay_eid = gameplay_core.create_entity(object)
        else
            local typeobject = iprototype:queryByName("entity", object.prototype_name)
            if iprototype:has_type(typeobject.type, "fluidbox") then -- TODO
                local typeobject_fluid = iprototype:queryByName("fluid", object.fluid_name)
                if not typeobject_fluid then
                    ifluidbox.update_fluidbox(gameplay_core.get_entity(object.gameplay_eid), 0)
                else
                    ifluidbox.update_fluidbox(gameplay_core.get_entity(object.gameplay_eid), typeobject_fluid.id)
                end
            end
        end
        needbuild = true
    end
    objects:commit("CONFIRM", "CONSTRUCTED")
    tile_objects:commit("CONFIRM", "CONSTRUCTED")

    if needbuild then
        gameplay_core.build()
    end

    datamodel.show_batch_mode_begin = false
    datamodel.show_construct_complete = false
end

local function batch_mode_begin(self, datamodel)
    assert(self.starting_coord == nil)
    local coord_indicator = assert(self.coord_indicator)
    self.starting_coord = {x = coord_indicator.x, y = coord_indicator.y}

    --
    datamodel.show_batch_mode_begin = false
    start(self, datamodel)
end

local function clean(self, datamodel)
    if self.coord_indicator then
        vsobject_manager:remove(self.coord_indicator.id)
        self.coord_indicator = nil
    end

    self:revert_changes({"INDICATOR", "TEMPORARY"})
    datamodel.show_batch_mode_begin = false
    datamodel.show_confirm = false
    self.super.clean(self, datamodel)
end

local function create()
    local builder = create_builder()

    local M = setmetatable({super = builder}, {__index = builder})
    M.new_entity = new_entity
    M.touch_move = touch_move
    M.touch_end = touch_end
    M.confirm = confirm
    M.complete = complete

    M.clean = clean

    M.prototype_name = ""
    -- M.starting_coord = {x = xx, y = xx}
    M.batch_mode_begin = batch_mode_begin
    return M
end
return create