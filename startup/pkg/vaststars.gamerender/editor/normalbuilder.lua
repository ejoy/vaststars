local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local camera = ecs.require "engine.camera"
local create_builder = ecs.require "editor.builder"
local ieditor = ecs.require "editor.editor"
local objects = require "objects"
local DEFAULT_DIR <const> = 'N'
local irecipe = require "gameplay.interface.recipe"
local global = require "global"
local iobject = ecs.require "object"
local ipower = ecs.require "power"
local ipower_line = ecs.require "power_line"
local imining = require "gameplay.interface.mining"
local math3d = require "math3d"
local iconstant = require "gameplay.interface.constant"
local logistic_coord = ecs.require "terrain"
local building_coord = require "global".building_coord_system
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local ALL_DIR = iconstant.ALL_DIR
local igrid_entity = ecs.require "engine.grid_entity"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local mc = import_package "ant.math".constant
local create_road_entrance = ecs.require "editor.road_entrance"
local GRID_POSITION_OFFSET <const> = math3d.constant("v4", {0, 0.2, 0, 0.0})
local create_sprite = ecs.require "sprite"
local SPRITE_COLOR = import_package "vaststars.prototype".load("sprite_color")
local idronecover = ecs.require "drone_cover"
local gameplay_core = require "gameplay.core"
local ichest = require "gameplay.interface.chest"
local assembling_common = require "ui_datamodel.common.assembling"
local gameplay = import_package "vaststars.gameplay"
local iassembling = gameplay.interface "assembling"
local igameplay = ecs.import.interface "vaststars.gamerender|igameplay"
local CREATE_BUILDING <const> = require "debugger".create_building

local function _building_to_logisitic(x, y)
    local nposition = assert(building_coord:get_begin_position_by_coord(x, y))
    nposition[1] = nposition[1] + 5
    nposition[3] = nposition[3] - 5
    local ncoord = logistic_coord:get_coord_by_position(math3d.vector(nposition)) -- building layer to logisitc layer
    if not ncoord then
        return
    end
    return ncoord[1], ncoord[2]
end

-- TODO: duplicate from roadbuilder.lua
local function _get_connections(prototype_name, x, y, dir)
    local typeobject = iprototype.queryByName(prototype_name)
    local r = {}
    if not typeobject.crossing then
        return r
    end

    for _, conn in ipairs(typeobject.crossing.connections) do
        local dx, dy, ddir = iprototype.rotate_connection(conn.position, dir, typeobject.area)
        r[#r+1] = {x = x + dx, y = y + dy, dir = ddir}
    end
    return r
end

local function _get_road_entrance_position(typeobject, x, y, dir)
    if not typeobject.crossing then
        return
    end
    local connections = _get_connections(typeobject.name, x, y, dir)
    local conn = connections[1]
    local succ, neighbor_x, neighbor_y = logistic_coord:move_coord(conn.x, conn.y, conn.dir, 1)
    if not succ then
        return
    end
    return logistic_coord:get_position_by_coord(neighbor_x, neighbor_y, 1, 1), neighbor_x, neighbor_y, conn.dir
end

local function __new_entity(self, datamodel, typeobject)
    iobject.remove(self.pickup_object)
    local dir = DEFAULT_DIR
    local x, y = iobject.central_coord(typeobject.name, dir, building_coord, 1)
    if not x or not y then
        return
    end
    local building_positon = building_coord:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, dir, 1, 1))
    x, y = _building_to_logisitic(x, y)

    local sprite_color
    if not self:check_construct_detector(typeobject.name, x, y, dir) then
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_INVALID
        elseif typeobject.power_supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_POWER_INVALID
        else
            sprite_color = SPRITE_COLOR.CONSTRUCT_INVALID
        end
        datamodel.show_confirm = false
        datamodel.show_rotate = (typeobject.rotate_on_build == true)
    else
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.DRONE_DEPOT_SUPPLY_AREA_VALID
        elseif typeobject.power_supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_POWER_VALID
        else
            sprite_color = SPRITE_COLOR.CONSTRUCT_VALID
        end
        datamodel.show_confirm = true
        datamodel.show_rotate = (typeobject.rotate_on_build == true)
    end

    -- some assembling machine have default recipe
    local fluid_name = ""
    if typeobject.recipe then
        local recipe_typeobject = iprototype.queryByName(typeobject.recipe)
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
        srt = {
            t = building_positon,
        },
        fluid_name = fluid_name,
    }
    iui.open({"construct_pop.rml"}, self.pickup_object.srt.t, typeobject.name)

    local offset_x, offset_y = 0, 0
    if typeobject.supply_area then
        local aw, ah = iprototype.unpackarea(typeobject.supply_area)
        local w, h = iprototype.rotate_area(typeobject.area, dir)
        offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        self.sprite = create_sprite(x + offset_x, y + offset_y, aw, ah, dir, sprite_color)
    elseif typeobject.power_supply_area then
        local aw, ah = typeobject.power_supply_area:match("(%d+)x(%d+)")
        local w, h = iprototype.rotate_area(typeobject.area, dir)
        offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        self.sprite = create_sprite(x + offset_x, y + offset_y, aw, ah, dir, sprite_color)
    else
        local w, h = iprototype.rotate_area(typeobject.area, dir)
        self.sprite = create_sprite(x + offset_x, y + offset_y, w, h, dir, sprite_color)
    end

    local road_entrance_position, _, _, road_entrance_dir = _get_road_entrance_position(typeobject, x, y, dir)
    if road_entrance_position then
        local srt = {t = road_entrance_position, r = ROTATORS[road_entrance_dir]}
        if datamodel.show_confirm then
            self.road_entrance = create_road_entrance(srt, "valid")
        else
            self.road_entrance = create_road_entrance(srt, "invalid")
        end
    end
end

local function __calc_grid_position(self, typeobject)
    local _, originPosition = building_coord:align(math3d.vector {0, 0, 0}, iprototype.unpackarea(typeobject.area))
    local buildingPosition = building_coord:get_begin_position_by_coord(_building_to_logisitic(self.pickup_object.x, self.pickup_object.y))
    return math3d.ref(math3d.add(math3d.sub(buildingPosition, originPosition), GRID_POSITION_OFFSET))
end

local function new_entity(self, datamodel, typeobject)
    if typeobject.power_supply_area and typeobject.power_supply_distance and not typeobject.supply_area then
        local sprite_color = SPRITE_COLOR.POWER_SUPPLY_AREA
        for _, object in objects:all() do
            local otypeobject = iprototype.queryByName(object.prototype_name)
            if otypeobject.power_supply_area then
                local w, h = iprototype.unpackarea(otypeobject.area)
                local ow, oh = otypeobject.power_supply_area:match("(%d+)x(%d+)")
                ow, oh = tonumber(ow), tonumber(oh)
                self.sprites[#self.sprites+1] = create_sprite(object.x - (ow - w)//2, object.y - (oh - h)//2, ow, oh, object.dir, sprite_color)
            end
        end
    end

    if iprototype.has_chest(typeobject.name) or typeobject.supply_area then
        local sprite_color = SPRITE_COLOR.DRONE_DEPOT_SUPPLY_AREA_2
        for _, object in objects:all() do
            local otypeobject = iprototype.queryByName(object.prototype_name)
            if otypeobject.supply_area then
                local w, h = iprototype.unpackarea(otypeobject.area)
                local ow, oh = iprototype.unpackarea(otypeobject.supply_area)
                ow, oh = tonumber(ow), tonumber(oh)
                self.sprites[#self.sprites+1] = create_sprite(object.x - (ow - w)//2, object.y - (oh - h)//2, ow, oh, object.dir, sprite_color)
            end
        end
    end

    __new_entity(self, datamodel, typeobject)
    self.pickup_object.APPEAR = true

    if not self.grid_entity then
        self.grid_entity = igrid_entity.create("polyline_grid", building_coord.tile_width, building_coord.tile_height, logistic_coord.tile_size, {t = __calc_grid_position(self, typeobject)})
        self.grid_entity:show(true)
    end
end

-- TODO: duplicate from builder.lua
local function _get_mineral_recipe(prototype_name, x, y, dir)
    local typeobject = iprototype.queryByName(prototype_name)
    local w, h = iprototype.rotate_area(typeobject.area, dir)

    if not iprototype.has_type(typeobject.type, "mining") then
        return
    end
    local found
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local mineral = logistic_coord:get_mineral(x + i, y + j) -- TODO: maybe have multiple minerals in the area
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

local function __align(object)
    assert(object)
    local typeobject = iprototype.queryByName(object.prototype_name)
    local coord, srt = building_coord:align(camera.get_central_position(), iprototype.rotate_area(typeobject.area, object.dir, 1, 1))
    if not coord then
        return object
    end
    object.srt.t = srt
    return object, coord[1], coord[2]
end

local function touch_move(self, datamodel, delta_vec)
    if not self.pickup_object then
        return
    end
    local pickup_object = self.pickup_object
    iobject.move_delta(pickup_object, delta_vec, building_coord, 1)

    local x, y
    self.pickup_object, x, y = __align(self.pickup_object)
    local lx, ly = _building_to_logisitic(x, y)
    if not lx then
        datamodel.show_confirm = false
        return
    end
    pickup_object.x, pickup_object.y = lx, ly

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)

    if self.road_entrance then
        local road_entrance_position, _, _, road_entrance_dir = _get_road_entrance_position(typeobject, lx, ly, pickup_object.dir)
        self.road_entrance:set_srt(mc.ONE, ROTATORS[road_entrance_dir], road_entrance_position)

        local t = {}
        for _, dir in ipairs(ALL_DIR) do
            local _, dx, dy = _get_road_entrance_position(typeobject, lx, ly, dir)
            if dx and dy then
                if global.roadnet[iprototype.packcoord(dx, dy)] then
                    t[#t+1] = dir
                end
            end
        end
        if #t == 1 and t[1] ~= pickup_object.dir then
            self:rotate_pickup_object(datamodel, t[1], delta_vec)
        end
    end

    if self.grid_entity then
        self.grid_entity:send("obj_motion", "set_position", __calc_grid_position(self, typeobject))
    end

    -- update temp pole
    if typeobject.power_supply_area and typeobject.power_supply_distance then
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh = typeobject.power_supply_area:match("(%d+)x(%d+)")
        ipower:merge_pole({power_network_link_target = 0, key = pickup_object.id, targets = {}, x = lx, y = ly, w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.power_supply_distance, smooth_pos = true, power_network_link = typeobject.power_network_link})
        ipower_line.update_temp_line(ipower:get_temp_pole())
    end

    if self.last_x == lx and self.last_y == ly then
        return
    end
    self.last_x, self.last_y = lx, ly

    local sprite_color
    local offset_x, offset_y = 0, 0
    local w, h = iprototype.rotate_area(typeobject.area, pickup_object.dir)
    if not self:check_construct_detector(pickup_object.prototype_name, lx, ly, pickup_object.dir) then -- TODO
        datamodel.show_confirm = false

        if self.road_entrance then
            self.road_entrance:set_state("invalid")
        end

        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_INVALID
            local aw, ah = iprototype.unpackarea(typeobject.supply_area)
            offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        elseif typeobject.power_supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_POWER_INVALID
            local aw, ah = typeobject.power_supply_area:match("(%d+)x(%d+)")
            offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        else
            sprite_color = SPRITE_COLOR.CONSTRUCT_INVALID
        end
        if self.sprite then
            self.sprite:move(pickup_object.x + offset_x, pickup_object.y + offset_y, sprite_color)
        end
        return
    else
        if self.road_entrance then
            self.road_entrance:set_state("valid")
        end
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.DRONE_DEPOT_SUPPLY_AREA_VALID
            local aw, ah = iprototype.unpackarea(typeobject.supply_area)
            offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        elseif typeobject.power_supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_POWER_VALID
            local aw, ah = typeobject.power_supply_area:match("(%d+)x(%d+)")
            offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        else
            sprite_color = SPRITE_COLOR.CONSTRUCT_VALID
        end
        if self.sprite then
            self.sprite:move(pickup_object.x + offset_x, pickup_object.y + offset_y, sprite_color)
        end
    end

    pickup_object.recipe = _get_mineral_recipe(pickup_object.prototype_name, lx, ly, pickup_object.dir) -- TODO: maybe set recipt according to entity type?

    if iprototype.has_type(typeobject.type, "hub") then
        idronecover.update_cover(pickup_object, typeobject)
    end
end

local function touch_end(self, datamodel)
    ieditor:revert_changes({"TEMPORARY"})

    touch_move(self, datamodel, {0, 0, 0})
end

local function confirm(self, datamodel)
    local pickup_object = assert(self.pickup_object)
    local succ = self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir)
    if not succ then
        log.info("can not construct")
        return
    end

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)
    pickup_object.state = "confirm"
    objects:set(pickup_object, "CONFIRM")
    pickup_object.PREPARE = true

    datamodel.show_confirm = false
    datamodel.show_rotate = false
    --
    if typeobject.power_supply_area and typeobject.power_supply_distance then
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh = typeobject.power_supply_area:match("(%d+)x(%d+)")
        ipower:merge_pole({power_network_link_target = 0, key = pickup_object.id, targets = {}, x = pickup_object.x, y = pickup_object.y, w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.power_supply_distance, power_network_link = typeobject.power_network_link}, true)
        ipower_line.update_temp_line(ipower:get_temp_pole())
    end

    self.pickup_object = nil
    if self.road_entrance then
        self.road_entrance:remove()
        self.road_entrance = nil
    end
    if self.sprite then
        self.sprite:remove()
        self.sprite = nil
    end
    idronecover.clear()
    self:complete(pickup_object.id, datamodel)
end

local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}

local function __deduct_item(self, e)
    gameplay_core.get_world():container_pickup(e.chest, self.item, 1)

    -- TODO: here it is assumed that e is either a construction center or a construction chest
    if e.assembling then
        local typeobject = iprototype.queryById(e.building.prototype)
        local _, results = assembling_common.get(gameplay_core.get_world(), e)
        assert(results and #results == 1)
        local multiple = math.max((results[1].limit // results[1].output_count) - 1, 0)
        if typeobject.recipe_max_limit and typeobject.recipe_max_limit.resultsLimit >= multiple then
            iassembling.set_option(gameplay_core.get_world(), e, {ingredientsLimit = multiple, resultsLimit = multiple})
            gameplay_core.build()
        end
    else
        for i = 1, 256 do
            local slot = ichest.chest_get(gameplay_core.get_world(), e.chest, i)
            if not slot or slot.amount <= 0 then
                if i == 1 then
                    -- no item in chest, remove chest
                    local object_id
                    for _, object in objects:selectall("gameplay_eid", e.eid, EDITOR_CACHE_NAMES) do
                        object_id = object.id
                        break
                    end
                    local object = assert(objects:get(object_id))
                    iobject.remove(object)
                    objects:remove(object_id)
                    local building = global.buildings[object_id]
                    if building then
                        for _, v in pairs(building) do
                            v:remove()
                        end
                    end

                    igameplay.remove_entity(object.gameplay_eid)
                    gameplay_core.remove_entity(object.gameplay_eid)
                    gameplay_core.build()
                    return false
                end
                break
            end
        end
    end

    for i = 1, 256 do
        local slot = ichest.chest_get(gameplay_core.get_world(), e.chest, i)
        if not slot then
            break
        end
        if slot.item == self.item and slot.amount - slot.lock_item > 0 then
            return 0
        end
    end
    return false
end

local function complete(self, object_id, datamodel)
    if CREATE_BUILDING and not self.gameplay_eid then
        self.super.complete(self, object_id)
        self:clean(datamodel)
        iui.redirect("construct.rml", "move_finish") -- TODO：remove this
        return
    end

    local e = gameplay_core.get_entity(assert(self.gameplay_eid))
    local continue_construct = __deduct_item(self, e)
    self.super.complete(self, object_id)

    if not continue_construct then
        self:clean(datamodel)
        iui.redirect("construct.rml", "move_finish") -- TODO：remove this
    else
        local object = assert(objects:get(object_id))
        local typeobject = iprototype.queryByName(object.prototype_name)
        new_entity(self, datamodel, typeobject)
    end
end

local function check_construct_detector(self, prototype_name, x, y, dir)
    local succ = self.super:check_construct_detector(prototype_name, x, y, dir)
    if not succ then
        return false
    end

    local typeobject = iprototype.queryByName(prototype_name)
    if typeobject.crossing then
        local valid = false
        for _, conn in ipairs(_get_connections(prototype_name, x, y, dir)) do
            local succ, dx, dy = logistic_coord:move_coord(conn.x, conn.y, conn.dir, 1)
            if not succ then
                goto continue
            end

            if global.roadnet[iprototype.packcoord(dx, dy)] then
                valid = true
                break
            end
            ::continue::
        end

        if not valid then
            return false
        end
    end

    return true
end

local function rotate_pickup_object(self, datamodel, dir, delta_vec)
    local pickup_object = assert(self.pickup_object)

    ieditor:revert_changes({"TEMPORARY"})
    dir = dir or iprototype.rotate_dir_times(pickup_object.dir, -1)

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)
    local coord = building_coord:align(camera.get_central_position(), iprototype.rotate_area(typeobject.area, dir, 1, 1))
    if not coord then
        return
    end

    if not self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, dir) then
        datamodel.show_confirm = false
        datamodel.show_rotate = (typeobject.rotate_on_build == true)
    else
        datamodel.show_confirm = true
        datamodel.show_rotate = (typeobject.rotate_on_build == true)
    end

    pickup_object.dir = dir

    local x, y = _building_to_logisitic(coord[1], coord[2])
    if not x then
        return
    end
    pickup_object.x, pickup_object.y = x, y

    local road_entrance_position, dx, dy, ddir = _get_road_entrance_position(typeobject, x, y, pickup_object.dir)
    if road_entrance_position then
        self.road_entrance:set_srt(mc.ONE, ROTATORS[ddir], road_entrance_position)
    end
end

local function clean(self, datamodel)
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end

    for _, sprite in ipairs(self.sprites) do
        sprite:remove()
    end
    self.sprites = {}

    ieditor:revert_changes({"TEMPORARY"})
    datamodel.show_confirm = false
    datamodel.show_rotate = false
    self.super.clean(self, datamodel)
    -- clear temp pole
    ipower:clear_all_temp_pole()
    ipower_line.update_temp_line(ipower:get_temp_pole())

    if self.road_entrance then
        self.road_entrance:remove()
        self.road_entrance = nil
    end
    if self.sprite then
        self.sprite:remove()
        self.sprite = nil
    end
    idronecover.clear()

    iui.close("construct_pop.rml")
end

local function create(gameplay_eid, item)
    local builder = create_builder()

    local M = setmetatable({super = builder}, {__index = builder})
    M.new_entity = new_entity
    M.touch_move = touch_move
    M.touch_end = touch_end
    M.confirm = confirm
    M.rotate_pickup_object = rotate_pickup_object
    M.clean = clean
    M.check_construct_detector = check_construct_detector
    M.complete = complete
    M.sprites = {}
    M.last_x, M.last_y = -1, -1
    M.gameplay_eid = gameplay_eid
    M.item = item

    return M
end
return create