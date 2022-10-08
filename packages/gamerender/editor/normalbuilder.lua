local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local ifluid = require "gameplay.interface.fluid"
local terrain = ecs.require "terrain"
local camera = ecs.require "engine.camera"
local create_builder = ecs.require "editor.builder"
local ieditor = ecs.require "editor.editor"
local objects = require "objects"
local DEFAULT_DIR <const> = 'N'
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local irecipe = require "gameplay.interface.recipe"
local global = require "global"
local iobject = ecs.require "object"
local ipower = ecs.require "power"
local imining = require "gameplay.interface.mining"
local inventory = global.inventory
local iui = ecs.import.interface "vaststars.gamerender|iui"
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local math3d = require "math3d"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ientity = ecs.import.interface "ant.render|ientity"
local imesh = ecs.import.interface "ant.asset|imesh"
local ivs = ecs.import.interface "ant.scene|ivisible_state"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local iconstant = require "gameplay.interface.constant"
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local ALL_DIR = iconstant.ALL_DIR
local CONSTRUCT_COLOR_ROADSIDE_ARROW <const> = math3d.constant("v4", {0.0, 1.0, 0.0, 1})
local CONSTRUCT_COLOR_ROADSIDE_BLOCK <const> = math3d.constant("v4", {0.0, 2.5, 0.0, 0.5})
local CONSTRUCT_COLOR_ROADSIDE_ARROW_INVALID <const> = math3d.constant("v4", {1.0, 0.0, 0.0, 1})
local CONSTRUCT_COLOR_ROADSIDE_BLOCK_INVALID <const> = math3d.constant("v4", {2.5, 0.0, 0.0, 0.5})

local function _get_state(prototype_name, ok)
    local typeobject = iprototype.queryByName("entity", prototype_name)
    if typeobject.supply_area then
        if ok then
            return ("power_pole_construct_%s"):format(typeobject.supply_area)
        else
            return ("power_pole_invalid_construct_%s"):format(typeobject.supply_area)
        end
    else
        if ok then
            return "construct"
        else
            return "invalid_construct"
        end
    end
end

-- TODO: duplicate from vsobject.lua
local entity_events = {}
entity_events["obj_motion"] = function(_, e, method, ...)
    iom[method](e, ...)
end
entity_events["material"] = function(_, e, method, ...)
    imaterial[method](e, ...)
end

local gen_id do
    local id = 0
    function gen_id()
        id = id + 1
        return id
    end
end

local plane_vb <const> = {
	-0.5, 0, 0.5, 0, 1, 0,	--left top
	0.5,  0, 0.5, 0, 1, 0,	--right top
	-0.5, 0,-0.5, 0, 1, 0,	--left bottom
	-0.5, 0,-0.5, 0, 1, 0,
	0.5,  0, 0.5, 0, 1, 0,
	0.5,  0,-0.5, 0, 1, 0,	--right bottom
}

local function create_block(color, width, height, position)
    local eid = ecs.create_entity{
		policy = {
			"ant.render|simplerender",
			"ant.general|name",
		},
		data = {
			scene 		= { s = {terrain.tile_size * width, 1, terrain.tile_size * height}, t = position},
			material 	= "/pkg/vaststars.resources/materials/translucent.material",
			visible_state= "main_view",
			name 		= ("plane_%d"):format(gen_id()),
			simplemesh 	= imesh.init_mesh(ientity.create_mesh({"p3|n3", plane_vb}, nil, math3d.ref(math3d.aabb({-0.5, 0, -0.5}, {0.5, 0, 0.5}))), true),
			on_ready = function (e)
				ivs.set_state(e, "main_view", true)
                imaterial.set_property(e, "u_basecolor_factor", color)
			end
		},
	}

    return ientity_object.create(eid, entity_events)
end

-- TODO: duplicate from roadbuilder.lua
local function _get_connections(prototype_name, x, y, dir)
    local typeobject = iprototype.queryByName("entity", prototype_name)
    local r = {}
    if not typeobject.crossing then
        return r
    end

    for _, conn in ipairs(typeobject.crossing.connections) do
        local dx, dy, dir = iprototype.rotate_fluidbox(conn.position, dir, typeobject.area)
        r[#r+1] = {x = x + dx, y = y + dy, dir = dir, roadside = conn.roadside}
    end
    return r
end

local function _get_roadside_position(typeobject, x, y, dir)
    if not typeobject.crossing then
        return
    end
    local connections = _get_connections(typeobject.name, x, y, dir)
    assert(#connections == 1) -- only one roadside
    local conn = connections[1]
    local succ, neighbor_x, neighbor_y = terrain:move_coord(conn.x, conn.y, conn.dir, 1)
    if not succ then
        return
    end
    return terrain:get_position_by_coord(neighbor_x, neighbor_y, 1, 1), neighbor_x, neighbor_y, conn.dir
end

local function __new_entity(self, datamodel, typeobject)
    -- check if item is in the inventory
    local item_typeobject = iprototype.queryByName("item", typeobject.name)
    local item = inventory:get(item_typeobject.id)
    if item.count <= 0 then
        log.error("Lack of item: " .. typeobject.name) -- TODO: show error message?
        return
    end

    iobject.remove(self.pickup_object)
    local dir = DEFAULT_DIR
    local x, y = iobject.central_coord(typeobject.name, dir)
    if not x or not y then
        return
    end

    local state
    if not self:check_construct_detector(typeobject.name, x, y, dir) then
        state = _get_state(typeobject.name, false)
        datamodel.show_confirm = false
        datamodel.show_rotate = true
    else
        state = _get_state(typeobject.name, true)
        datamodel.show_confirm = true
        datamodel.show_rotate = true
    end

    -- some assembling machine have default recipe
    local fluid_name = ""
    if typeobject.recipe then
        local recipe_typeobject = iprototype.queryByName("recipe", typeobject.recipe)
        if recipe_typeobject then
            fluid_name = irecipe.get_init_fluids(recipe_typeobject) or "" -- maybe no fluid in recipe
        else
            fluid_name = ""
        end
    end

    self.pickup_object = iobject.new {
        prototype_name = typeobject.name,
        dir = dir,
        x = x,
        y = y,
        fluid_name = fluid_name,
        state = state,
    }

    local roadside_position = _get_roadside_position(typeobject, x, y, dir)
    if roadside_position then
        self.roadside_position = roadside_position

        if datamodel.show_confirm then
            self.roadside_block = create_block(CONSTRUCT_COLOR_ROADSIDE_BLOCK, 1, 1, roadside_position)
        else
            self.roadside_block = create_block(CONSTRUCT_COLOR_ROADSIDE_BLOCK_INVALID, 1, 1, roadside_position)
        end

        if datamodel.show_confirm then
            self.roadside_arrow = assert(igame_object.create({
                state = "translucent",
                color = CONSTRUCT_COLOR_ROADSIDE_ARROW,
                prefab = "prefabs/road/roadside_arrow.prefab",
                group_id = 0,
                srt = {t = roadside_position},
            }))
        else
            self.roadside_arrow = assert(igame_object.create({
                state = "translucent",
                color = CONSTRUCT_COLOR_ROADSIDE_ARROW_INVALID,
                prefab = "prefabs/road/roadside_arrow.prefab",
                group_id = 0,
                srt = {t = roadside_position},
            }))
        end
    end
end

local function new_entity(self, datamodel, typeobject)
    __new_entity(self, datamodel, typeobject)
    self.pickup_object.__object.APPEAR = true
end

-- TODO: duplicate from builder.lua
local function _get_mineral_recipe(prototype_name, x, y, dir)
    local typeobject = iprototype.queryByName("entity", prototype_name)
    local w, h = iprototype.rotate_area(typeobject.area, dir)

    if not iprototype.has_type(typeobject.type, "mining") then
        return
    end
    local found
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local mineral = terrain:get_mineral(x + i, y + j) -- TODO: maybe have multiple minerals in the area
            if mineral then
                found = mineral
            end
        end
    end

    if not found then
        return
    end

    return imining.get_mineral_recipe(prototype_name, found)
end

local function _update_fluid_name(self, datamodel, object, failed, x, y, dir) -- TODO: optimize x, y, dir
    if not ifluid:need_set_fluid(object.prototype_name) then
        if failed == false then
            object.state = _get_state(object.prototype_name, true)
            datamodel.show_confirm = true
        end
        datamodel.show_rotate = true
        return
    end

    local fluid_types = self:get_neighbor_fluid_types(EDITOR_CACHE_NAMES, object.prototype_name, x or object.x, y or object.y, dir or object.dir)
    if #fluid_types <= 1 then
        object.fluid_name = fluid_types[1] or ""
        if failed == false then
            object.state = _get_state(object.prototype_name, true)
            datamodel.show_confirm = true
        end
        datamodel.show_rotate = true
        return
    else
        object.fluid_name = ""
        object.state = _get_state(object.prototype_name, false)
    end
end

local function touch_move(self, datamodel, delta_vec)
    if self.pickup_object then
        local pickup_object = self.pickup_object
        iobject.move_delta(pickup_object, delta_vec)

        local typeobject = iprototype.queryByName("entity", pickup_object.prototype_name)
        local coord = terrain:align(camera.get_central_position(), iprototype.rotate_area(typeobject.area, pickup_object.dir))
        if not coord then
            pickup_object.state = _get_state(pickup_object.prototype_name, false)
            datamodel.show_confirm = false
            return
        end

        if self.roadside_position then
            self.roadside_position = math3d.ref(math3d.add(self.roadside_position, delta_vec))

            self.roadside_block:send("obj_motion", "set_position", self.roadside_position)
            self.roadside_block:send("obj_motion", "set_rotation", ROTATORS[pickup_object.dir])

            self.roadside_arrow:send("obj_motion", "set_position", self.roadside_position)
            self.roadside_arrow:send("obj_motion", "set_rotation", ROTATORS[pickup_object.dir])

            local t = {}
            for _, dir in ipairs(ALL_DIR) do
                local _, dx, dy = _get_roadside_position(typeobject, coord[1], coord[2], dir)
                if dx and dy then
                    local road = objects:coord(dx, dy, EDITOR_CACHE_NAMES)
                    if road and iprototype.is_road(road.prototype_name) then
                        t[#t+1] = dir
                    end
                end
            end
            if #t == 1 and t[1] ~= pickup_object.dir then
                self:rotate_pickup_object(datamodel, t[1], delta_vec)
            end
        end

        if not self:check_construct_detector(pickup_object.prototype_name, coord[1], coord[2], pickup_object.dir) then
            pickup_object.state = _get_state(pickup_object.prototype_name, false)
            datamodel.show_confirm = false

            if self.roadside_block then
                self.roadside_block:send("material", "set_property", "u_basecolor_factor", CONSTRUCT_COLOR_ROADSIDE_BLOCK_INVALID)
                self.roadside_arrow:update("prefabs/road/roadside_arrow.prefab", "translucent", CONSTRUCT_COLOR_ROADSIDE_ARROW_INVALID)
            end
            return
        else
            if self.roadside_block then
                self.roadside_block:send("material", "set_property", "u_basecolor_factor", CONSTRUCT_COLOR_ROADSIDE_BLOCK)
                self.roadside_arrow:update("prefabs/road/roadside_arrow.prefab", "translucent", CONSTRUCT_COLOR_ROADSIDE_ARROW)
            end
        end

        pickup_object.recipe = _get_mineral_recipe(pickup_object.prototype_name, coord[1], coord[2], pickup_object.dir) -- TODO: maybe set recipt according to entity type?
        _update_fluid_name(self, datamodel, pickup_object, false, coord[1], coord[2], pickup_object.dir)

        -- update temp pole
        if typeobject.supply_area and typeobject.supply_distance then
            local aw, ah = iprototype.unpackarea(typeobject.area)
            local sw, sh = typeobject.supply_area:match("(%d+)x(%d+)")
            ipower.merge_pole({key = pickup_object.id, targets = {}, x = coord[1], y = coord[2], w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.supply_distance, smooth_pos = true})
        end
    end
end

local function touch_end(self, datamodel)
    ieditor:revert_changes({"TEMPORARY"})

    local pickup_object = self.pickup_object
    if not pickup_object then
        return
    end

    iobject.align(self.pickup_object)

    local typeobject = iprototype.queryByName("entity", pickup_object.prototype_name)

    local dx, dy, ddir
    self.roadside_position, dx, dy, ddir = _get_roadside_position(typeobject, pickup_object.x, pickup_object.y, pickup_object.dir)
    if self.roadside_position then
        local iflow_connector = require "gameplay.interface.flow_connector"
        self.roadside_block:send("obj_motion", "set_position", self.roadside_position)
        self.roadside_block:send("obj_motion", "set_rotation", ROTATORS[pickup_object.dir])

        self.roadside_arrow:send("obj_motion", "set_position", self.roadside_position)
        self.roadside_arrow:send("obj_motion", "set_rotation", ROTATORS[pickup_object.dir])

        local obj = objects:coord(dx, dy, EDITOR_CACHE_NAMES)
        if obj and iprototype.is_road(obj.prototype_name) then
            obj = assert(objects:modify(dx, dy, EDITOR_CACHE_NAMES, iobject.clone))
            obj.prototype_name, obj.dir = iflow_connector.covers_roadside(obj.prototype_name, obj.dir, iprototype.reverse_dir(ddir), true)
        end
    end

    if not self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) then
        pickup_object.state = _get_state(pickup_object.prototype_name, false)
        datamodel.show_confirm = false
        if self.roadside_block then
            self.roadside_block:send("material", "set_property", "u_basecolor_factor", CONSTRUCT_COLOR_ROADSIDE_BLOCK_INVALID)
            self.roadside_arrow:update("prefabs/road/roadside_arrow.prefab", "translucent", CONSTRUCT_COLOR_ROADSIDE_ARROW_INVALID)
        end
        return
    else
        if self.roadside_block then
            self.roadside_block:send("material", "set_property", "u_basecolor_factor", CONSTRUCT_COLOR_ROADSIDE_BLOCK)
            self.roadside_arrow:update("prefabs/road/roadside_arrow.prefab", "translucent", CONSTRUCT_COLOR_ROADSIDE_ARROW)
        end
    end

    pickup_object.recipe = _get_mineral_recipe(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) -- TODO: maybe set recipt according to entity type?
    _update_fluid_name(self, datamodel, pickup_object, false)

    -- update temp pole
    if typeobject.supply_area and typeobject.supply_distance then
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh = typeobject.supply_area:match("(%d+)x(%d+)")
        ipower.merge_pole({key = pickup_object.id, targets = {}, x = self.pickup_object.x, y = self.pickup_object.y, w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.supply_distance})
    end
end

local iflow_connector = require "gameplay.interface.flow_connector"
local function _get_item_name(prototype_name)
    local typeobject = iprototype.queryByName("item", iflow_connector.covers(prototype_name, DEFAULT_DIR))
    return typeobject.name
end

local function confirm(self, datamodel)
    local pickup_object = assert(self.pickup_object)
    local succ, replaced_objects = self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir)
    if not succ then
        log.info("can not construct")
        return
    end

    local typeobject = iprototype.queryByName("entity", pickup_object.prototype_name)
    if iprototype.has_type(typeobject.type, "fluidbox") then
        -- fluid_name of object has been set in touch_end(), so we don't need to set it again
        global.fluidflow_id = global.fluidflow_id + 1
        pickup_object.fluidflow_id = global.fluidflow_id
    end

    if iprototype.has_type(typeobject.type, "fluidboxes") then
        self:update_fluidbox(EDITOR_CACHE_NAMES, "CONFIRM", pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir, pickup_object.fluid_name)
    end

    --
    for _, object in ipairs(replaced_objects) do
        local _obj = assert(objects:modify(object.x, object.y, EDITOR_CACHE_NAMES, iobject.clone))
        iobject.remove(_obj)

        local item_name = _get_item_name(object.prototype_name)
        local item_typeobject = iprototype.queryByName("item", item_name)
        assert(inventory:increase(item_typeobject.id, 1))
    end
    objects:commit("TEMPORARY", "CONFIRM")

    if typeobject.supply_area then
        pickup_object.state = ("power_pole_confirm_%s"):format(typeobject.supply_area)
    else
        pickup_object.state = "confirm"
    end
    objects:set(pickup_object, "CONFIRM")
    pickup_object.PREPARE = true

    local item_typeobject = iprototype.queryByName("item", typeobject.name)
    assert(inventory:decrease(item_typeobject.id, 1)) -- promised by new_entity
    inventory:confirm()
    iui.update("construct.rml", "update_construct_inventory")

    datamodel.show_confirm = false
    datamodel.show_rotate = false
    datamodel.show_construct_complete = true
    --
    if typeobject.supply_area and typeobject.supply_distance then
        local coord = terrain:align(camera.get_central_position(), iprototype.rotate_area(typeobject.area, pickup_object.dir))
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh = typeobject.supply_area:match("(%d+)x(%d+)")
        ipower.merge_pole({key = pickup_object.id, targets = {}, x = coord[1], y = coord[2], w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.supply_distance}, true)
    end

    self.pickup_object = nil
    if self.roadside_position then
        self.roadside_block:remove()
        self.roadside_arrow:remove()
        self.roadside_block = nil
        self.roadside_arrow = nil
        self.roadside_position = nil
    end
    __new_entity(self, datamodel, typeobject)
end

local function complete(self, datamodel)
    if not inventory:complete() then
        return
    end

    iobject.remove(self.pickup_object)
    self.pickup_object = nil

    ieditor:revert_changes({"TEMPORARY", "POWER_AREA"})
    datamodel.show_construct_complete = false
    datamodel.show_rotate = false
    datamodel.show_confirm = false

    self.super.complete(self)

    if self.roadside_block then
        self.roadside_block:remove()
    end
    if self.roadside_arrow then
        self.roadside_arrow:remove()
    end
end

local function check_construct_detector(self, prototype_name, x, y, dir)
    local succ, replaced_objects = self.super:check_construct_detector(prototype_name, x, y, dir)
    if not succ then
        return false
    end

    if not ifluid:need_set_fluid(prototype_name) then
        return true, replaced_objects
    end

    local fluid_types = self:get_neighbor_fluid_types(EDITOR_CACHE_NAMES, prototype_name, x, y, dir)
    if #fluid_types > 1 then
        return false
    end
    return true, replaced_objects
end

local function rotate_pickup_object(self, datamodel, dir, delta_vec)
    local pickup_object = assert(self.pickup_object)

    ieditor:revert_changes({"TEMPORARY"})
    dir = dir or iprototype.rotate_dir_times(pickup_object.dir, -1)

    local typeobject = iprototype.queryByName("entity", pickup_object.prototype_name)
    local coord = terrain:align(camera.get_central_position(), iprototype.rotate_area(typeobject.area, dir))
    if not coord then
        return
    end

    local failed = false
    if not self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, dir) then
        pickup_object.state = _get_state(pickup_object.prototype_name, false)
        datamodel.show_confirm = false
        datamodel.show_rotate = true
        failed = true
    else
        pickup_object.state = _get_state(pickup_object.prototype_name, true)
        datamodel.show_confirm = true
        datamodel.show_rotate = true
    end

    pickup_object.dir = dir
    pickup_object.x, pickup_object.y = coord[1], coord[2]
    _update_fluid_name(self, datamodel, pickup_object, failed)

    self.roadside_position = _get_roadside_position(typeobject, pickup_object.x, pickup_object.y, pickup_object.dir)
    if self.roadside_position then
        self.roadside_block:send("obj_motion", "set_position", self.roadside_position)
        self.roadside_block:send("obj_motion", "set_rotation", ROTATORS[pickup_object.dir])

        self.roadside_arrow:send("obj_motion", "set_position", self.roadside_position)
        self.roadside_arrow:send("obj_motion", "set_rotation", ROTATORS[pickup_object.dir])
    end
end

local function clean(self, datamodel)
    ieditor:revert_changes({"TEMPORARY"})
    inventory:revert()
    datamodel.show_confirm = false
    datamodel.show_rotate = false
    self.super.clean(self, datamodel)
    -- clear temp pole
    ipower.clear_all_temp_pole()

    if self.roadside_block then
        self.roadside_block:remove()
    end
    if self.roadside_arrow then
        self.roadside_arrow:remove()
    end
end

local function create()
    local builder = create_builder()

    local M = setmetatable({super = builder}, {__index = builder})
    M.new_entity = new_entity
    M.touch_move = touch_move
    M.touch_end = touch_end
    M.confirm = confirm
    M.complete = complete
    M.rotate_pickup_object = rotate_pickup_object

    M.check_construct_detector = check_construct_detector
    M.clean = clean

    return M
end
return create