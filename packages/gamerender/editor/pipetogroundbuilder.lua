local ecs = ...
local world = ecs.world
local w = world.w

local STATE_NONE  <const> = 0
local STATE_START <const> = 1
local EDITOR_CACHE_CONSTRUCTED = {"CONFIRM", "CONSTRUCTED"}
local EDITOR_CACHE_TEMPORARY   = {"TEMPORARY", "INDICATOR"}
local dotted_line_material <const> = "/pkg/vaststars.resources/materials/dotted_line.material"
local DEFAULT_DIR <const> = require("gameplay.interface.constant").DEFAULT_DIR

local create_builder = ecs.require "editor.builder"
local iobject = ecs.require "object"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local iquad_lines_entity = ecs.require "engine.quad_lines_entity"
local ieditor = ecs.require "editor.editor"
local is_valid_starting = ecs.require "editor.pipe-to-ground.is_valid_starting"
local state_start_func = ecs.require "editor.pipe-to-ground.state_start"
local show_indicator = ecs.require "editor.pipe-to-ground.util".show_indicator
local global = require "global"
local construct_inventory = global.construct_inventory
local _VASTSTARS_DEBUG_INFINITE_ITEM <const> = world.args.ecs.VASTSTARS_DEBUG_INFINITE_ITEM
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iworld = require "gameplay.interface.world"
local gameplay_core = require "gameplay.core"

local function state_init(self, datamodel)
    if not is_valid_starting(self.coord_indicator.x, self.coord_indicator.y) then
        datamodel.show_laying_pipe_begin = false
        self.coord_indicator.state = "invalid_construct"
        return
    else
        datamodel.show_laying_pipe_begin = true
        self.coord_indicator.state = "construct"

        --
        local object = objects:coord(self.coord_indicator.x, self.coord_indicator.y, EDITOR_CACHE_CONSTRUCTED)
        if not object then
            return
        end

        local typeobject = iprototype.queryByName("entity", object.prototype_name)
        if typeobject.pipe or typeobject.pipe_to_ground then
            return
        end
        show_indicator(self.coord_indicator.prototype_name, object)
        return
    end
end

local function state_start(self, datamodel)
    ieditor:revert_changes(EDITOR_CACHE_TEMPORARY)
    self.dotted_line:show(false)
    state_start_func(self, datamodel)
end

--
local function new_entity(self, datamodel, typeobject)
    if self.coord_indicator then
        iobject.remove(self.coord_indicator)
    end

    if not _VASTSTARS_DEBUG_INFINITE_ITEM then
        -- check if item is in the inventory
        local item_typeobject = iprototype.queryByName("item", typeobject.name)
        local item = construct_inventory:get({"TEMPORARY", "CONFIRM"}, item_typeobject.id)
        if not item or item.count <= 0 then
            log.error("Lack of item: " .. typeobject.name)
            return
        end
    end

    local dir = DEFAULT_DIR
    local x, y = iobject.central_coord(typeobject.name, dir)
    if not x or not y then
        return
    end

    self.typeobject = typeobject
    self.coord_indicator = iobject.new {
        prototype_name = typeobject.name,
        dir = "N",
        x = x,
        y = y,
        fluid_name = "",
        state = "construct",
    }

    state_init(self, datamodel)
end

local function laying_pipe_begin(self, datamodel)
    assert(is_valid_starting(self.coord_indicator.x, self.coord_indicator.y))
    datamodel.show_laying_pipe_begin = false

    self.state = STATE_START
    self.from_x = self.coord_indicator.x
    self.from_y = self.coord_indicator.y
    self.dotted_line = iquad_lines_entity.create(dotted_line_material)

    state_start(self, datamodel)
end

local function laying_pipe_cancel(self, datamodel)
    ieditor:revert_changes(EDITOR_CACHE_TEMPORARY)
    self:clean(datamodel)
    self:new_entity(datamodel, self.typeobject)
    datamodel.show_laying_pipe_confirm = false
    datamodel.show_laying_pipe_cancel = false
    datamodel.show_construct_complete = true
end

local function laying_pipe_confirm(self, datamodel)
    ieditor:revert_changes({EDITOR_CACHE_TEMPORARY[2]})

    for _, object in objects:all("TEMPORARY") do
        object.state = "confirm"
        object.PREPARE = true
    end
    objects:commit("TEMPORARY", "CONFIRM")

    self:clean(datamodel)
    self:new_entity(datamodel, self.typeobject)
    datamodel.show_laying_pipe_confirm = false
    datamodel.show_laying_pipe_cancel = false
    datamodel.show_construct_complete = true
end

local function touch_move(self, datamodel, delta_vec)
    iobject.move_delta(self.coord_indicator, delta_vec)
end

local function touch_end(self, datamodel)
    iobject.align(self.coord_indicator)
    ieditor:revert_changes(EDITOR_CACHE_TEMPORARY)
    construct_inventory:clear({"TEMPORARY"})

    if self.state ~= STATE_START then
        state_init(self, datamodel)
    else
        state_start(self, datamodel)
    end
end

local function complete(self, datamodel)
    local gameplay_world = gameplay_core.get_world()
    local e = iworld:get_headquater_entity(gameplay_world)
    if not e then
        log.error("can not find headquater entity")
        return
    end

    local failed = false
    for _, item in construct_inventory:all("TEMPORARY") do
        local old_item = assert(construct_inventory:get({"CONFIRM"}, item.prototype))
        assert(old_item.count >= item.count)
        local decrease = old_item.count - item.count
        print(iprototype.queryById(item.prototype).name, decrease)
        if not gameplay_world:container_pickup(e.chest.container, item.prototype, decrease) then
            log.error("can not pickup item", iprototype.queryById(item.prototype).name, decrease)
            failed = true
        end
    end
    if failed then
        return
    end

    ieditor:revert_changes(EDITOR_CACHE_TEMPORARY)

    self.super.complete(self)

    self:clean(datamodel)
    datamodel.show_construct_complete = false
end

local function clean(self, datamodel)
    ieditor:revert_changes(EDITOR_CACHE_TEMPORARY)

    self.state = STATE_NONE

    if self.coord_indicator then
        iobject.remove(self.coord_indicator)
        self.coord_indicator = nil
    end
    if self.dotted_line then
        self.dotted_line:remove()
        self.dotted_line = nil
    end
    self.from_x = nil
    self.from_y = nil
    self.shape = nil -- TODO: remove this
    self.shape_dir = nil -- TODO: remove this

    datamodel.show_laying_pipe_confirm = false
    datamodel.show_laying_pipe_cancel = false
    datamodel.show_laying_pipe_begin = false
end

local function create()
    local builder = create_builder()

    local M = setmetatable({super = builder}, {__index = builder})
    M.new_entity = new_entity
    M.touch_move = touch_move
    M.touch_end = touch_end
    M.complete = complete

    M.clean = clean
    M.laying_pipe_begin = laying_pipe_begin
    M.laying_pipe_cancel = laying_pipe_cancel
    M.laying_pipe_confirm = laying_pipe_confirm

    M.state = STATE_NONE

    -- M.typeobject -- TODO
    -- M.coord_indicator
    -- M.dotted_line
    -- M.from_x
    -- M.from_y
    return M
end
return create