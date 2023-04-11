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
local iplant = ecs.require "engine.plane"
local terrain = ecs.require "terrain"
local gameplay = import_package "vaststars.gameplay"
local iassembling = gameplay.interface "assembling"
local assembling_common = require "ui_datamodel.common.assembling"
local BLOCK_CONSTRUCT_COLOR_INVALID <const> = math3d.constant("v4", {2.5, 0.2, 0.2, 0.4})
local BLOCK_CONSTRUCT_COLOR_VALID <const> = math3d.constant("v4", {0.0, 1, 0.0, 1.0})
local BLOCK_POWER_SUPPLY_AREA_COLOR_VALID <const> = math3d.constant("v4", {0.13, 1.75, 2.4, 0.5})
local BLOCK_POWER_SUPPLY_AREA_COLOR_INVALID <const> = math3d.constant("v4", {2.5, 0.0, 0.0, 1.0})
local GRID_POSITION_OFFSET <const> = math3d.constant("v4", {0, 0.2, 0, 0.0})
local BLOCK_POSITION_OFFSET <const> = math3d.constant("v4", {0, 0.2, 0, 0.0})
local BLOCK_EDGE_SIZE <const> = 6

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

    local block_color
    if not self:check_construct_detector(typeobject.name, x, y, dir) then
        if typeobject.power_supply_area then
            block_color = BLOCK_POWER_SUPPLY_AREA_COLOR_INVALID
        else
            block_color = BLOCK_CONSTRUCT_COLOR_INVALID
        end
        datamodel.show_confirm = false
        datamodel.show_rotate = true
    else
        if typeobject.power_supply_area then
            block_color = BLOCK_POWER_SUPPLY_AREA_COLOR_VALID
        else
            block_color = BLOCK_CONSTRUCT_COLOR_VALID
        end
        datamodel.show_confirm = true
        datamodel.show_rotate = true
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
    iui.open({"construct_pop.rml"}, self.pickup_object.srt.t)

    local block_pos = math3d.ref(math3d.add(building_positon, BLOCK_POSITION_OFFSET))
    local w, h
    if typeobject.power_supply_area then
        w, h = typeobject.power_supply_area:match("(%d+)x(%d+)")
    else
        w, h = iprototype.rotate_area(typeobject.area, dir, 1, 1)
    end

    local srt = {r = ROTATORS[dir], s = {logistic_coord.tile_size * w, 1, logistic_coord.tile_size * h}, t = block_pos}
    self.block = iplant.create("/pkg/vaststars.resources/materials/singlecolor.material", "u_color", block_color, srt)

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

local function __show_block(self, position, dir, color, w, h)
    self.blocks[#self.blocks+1] = iplant.create("/pkg/vaststars.resources/materials/singlecolor.material", "u_color", color,
        {
            s = {terrain.tile_size * w + BLOCK_EDGE_SIZE, 1, terrain.tile_size * h + BLOCK_EDGE_SIZE},
            r = ROTATORS[dir],
            t = math3d.ref(math3d.add(position, BLOCK_POSITION_OFFSET))
        }
    )
end

local function new_entity(self, datamodel, typeobject)
    __new_entity(self, datamodel, typeobject)
    self.pickup_object.APPEAR = true

    if not self.grid_entity then
        self.grid_entity = igrid_entity.create("polyline_grid", building_coord.tile_width, building_coord.tile_height, logistic_coord.tile_size, {t = __calc_grid_position(self, typeobject)})
        self.grid_entity:show(true)
    end
    if typeobject.power_supply_area and typeobject.power_supply_distance then
        local block_color = BLOCK_POWER_SUPPLY_AREA_COLOR_VALID
        for _, object in objects:all() do
            local otypeobject = iprototype.queryByName(object.prototype_name)
            if otypeobject.power_supply_area then
                local ow, oh = otypeobject.power_supply_area:match("(%d+)x(%d+)")
                ow, oh = tonumber(ow), tonumber(oh)
                __show_block(self, object.srt.t, object.dir, block_color, ow, oh)
            end
        end
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

    if self.block then
        local block_pos = math3d.ref(math3d.add(pickup_object.srt.t, BLOCK_POSITION_OFFSET))
        self.block:send("obj_motion", "set_position", block_pos)
    end
    if self.grid_entity then
        self.grid_entity:send("obj_motion", "set_position", __calc_grid_position(self, typeobject))
    end

    local block_color
    if not self:check_construct_detector(pickup_object.prototype_name, lx, ly, pickup_object.dir) then -- TODO
        datamodel.show_confirm = false

        if self.road_entrance then
            self.road_entrance:set_state("invalid")
        end
        if self.block then
            if typeobject.power_supply_area then
                block_color = BLOCK_POWER_SUPPLY_AREA_COLOR_INVALID
            else
                block_color = BLOCK_CONSTRUCT_COLOR_INVALID
            end
            if typeobject.power_supply_area then
                block_color = BLOCK_POWER_SUPPLY_AREA_COLOR_INVALID
            else
                block_color = BLOCK_CONSTRUCT_COLOR_INVALID
            end
            self.block:send("set_color", block_color)
        end
        return
    else
        if self.road_entrance then
            self.road_entrance:set_state("valid")
        end
        if self.block then
            if typeobject.power_supply_area then
                block_color = BLOCK_POWER_SUPPLY_AREA_COLOR_VALID
            else
                block_color = BLOCK_CONSTRUCT_COLOR_VALID
            end
            self.block:send("set_color", block_color)
        end
    end

    pickup_object.recipe = _get_mineral_recipe(pickup_object.prototype_name, lx, ly, pickup_object.dir) -- TODO: maybe set recipt according to entity type?

    -- update temp pole
    if typeobject.power_supply_area and typeobject.power_supply_distance then
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh = typeobject.power_supply_area:match("(%d+)x(%d+)")
        ipower:merge_pole({power_network_link_target = 0, key = pickup_object.id, targets = {}, x = lx, y = ly, w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.power_supply_distance, smooth_pos = true, power_network_link = typeobject.power_network_link})
        ipower_line.update_temp_line(ipower:get_temp_pole())
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
    if self.block then
        self.block:remove()
        self.block = nil
    end

    iui.close("construct_pop.rml")
    self:complete(pickup_object.id, datamodel)
end

-- TODO: remove this
local gameplay_core = require "gameplay.core"
local ichest = require "gameplay.interface.chest"
-- local gameplay = import_package "vaststars.gameplay"
-- local ihub = gameplay.interface "hub"

-- local function __set_hub_first_item(gameplay_world, e, prototype_name)
--     ihub.set_item(gameplay_world, e, prototype_name)
-- end

-- local function __get_hub_first_item(gameplay_world, e)
--     local slot = ichest.chest_get(gameplay_world, e.hub, 1)
--     if slot then
--         return slot.item
--     end
-- end

-- local function __set_station_first_item(gameplay_world, e, prototype_name)
--     local station = e.station
--     gameplay_world:container_destroy(station)

--     local typeobject = iprototype.queryById(e.building.prototype)
--     local typeobject_item = iprototype.queryByName(prototype_name)
--     local c = {}
--     c[#c+1] = gameplay_world:chest_slot {
--         type = typeobject.chest_type,
--         item = typeobject_item.id,
--         limit = 1,
--     }
--     station.chest = gameplay_world:container_create(table.concat(c))

--     e.chest.chest = station.chest
-- end

-- local function __get_station_first_item(gameplay_world, e)
--     local slot = ichest.chest_get(gameplay_world, e.station, 1)
--     if slot then
--         return slot.item
--     end
-- end

local function __deduct_item(self, e)
    gameplay_core.get_world():container_pickup(e.chest, self.item, 1)

    local typeobject = iprototype.queryById(e.building.prototype)
    local _, results = assembling_common.get(gameplay_core.get_world(), e)
    assert(results and #results == 1)
    local multiple = math.max((results[1].limit // results[1].output_count) - 1, 0)
    if typeobject.recipe_max_limit and typeobject.recipe_max_limit.resultsLimit >= multiple then
        iassembling.set_option(gameplay_core.get_world(), e, {ingredientsLimit = multiple, resultsLimit = multiple})
        gameplay_core.build()
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

local iroadnet = ecs.require "roadnet"
local MAPPING <const> = {
    W = 0, -- left
    N = 1, -- top
    E = 2, -- right
    S = 3, -- bottom
}

-- TODO：duplicate codes
local function __set_state_value(num, dir)
    local index = MAPPING[dir]
    assert(index >= 0 and index <= 3)
    num = num & ~(1 << index) | (1 << index)
    return num
end

local function complete(self, object_id, datamodel)
    local e = gameplay_core.get_entity(assert(self.gameplay_eid))
    local continue_construct = __deduct_item(self, e)

    self.super.complete(self, object_id)

    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end

    local typeobject = iprototype.queryByName(object.prototype_name)
    local rd = _get_connections(object.prototype_name, object.x, object.y, object.dir)
    if #rd == 1 then
        local dx, dy = iprototype.move_coord(rd[1].x, rd[1].y, rd[1].dir, 1)
        local mask = assert(global.roadnet[iprototype.packcoord(dx, dy)])
        mask = __set_state_value(mask, iprototype.reverse_dir(rd[1].dir))
        global.roadnet[iprototype.packcoord(dx, dy)] = mask
        global.roadnet[iprototype.packcoord(rd[1].x, rd[1].y)] = 0x10
        iroadnet:editor_build()
    end

    print("complete -------- ", continue_construct)
    if not continue_construct then
        self:clean(datamodel)
        iui.redirect("construct.rml", "move_finish") -- TODO：remove this
    else
        new_entity(self, datamodel, typeobject)
    end

    -- must be placed last, otherwise it will block the UI interface opened by new_entity()
    -- if iprototype.has_type(typeobject.type, "hub") then
    --     local interface = {} -- TODO: remove this
    --     interface.get_first_item = __get_hub_first_item
    --     interface.set_first_item = __set_hub_first_item
    --     iui.open({"drone_depot.rml"}, object_id, interface)
    -- end
    -- if iprototype.has_type(typeobject.type, "station") then
    --     local interface = {} -- TODO: remove this
    --     interface.get_first_item = __get_station_first_item
    --     interface.set_first_item = __set_station_first_item
    --     iui.open({"drone_depot.rml"}, object_id, interface)
    -- end
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
        datamodel.show_rotate = true
    else
        datamodel.show_confirm = true
        datamodel.show_rotate = true
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

    for _, block in ipairs(self.blocks) do
        block:remove()
    end
    self.blocks = {}

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
    if self.block then
        self.block:remove()
        self.block = nil
    end

    iui.close("construct_pop.rml")
end

local function create(gameplay_eid, item)
    local builder = create_builder()

    local M = setmetatable({super = builder}, {__index = builder})
    M.new_entity = new_entity
    M.touch_move = touch_move
    M.touch_end = touch_end
    M.confirm = confirm
    M.complete = complete
    M.rotate_pickup_object = rotate_pickup_object
    M.clean = clean
    M.check_construct_detector = check_construct_detector
    M.blocks = {}

    M.gameplay_eid = gameplay_eid
    M.item = item

    return M
end
return create