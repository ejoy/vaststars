local ecs = ...
local world = ecs.world
local w = world.w

local COLOR <const> = ecs.require "vaststars.prototype|color"
local SELECTION_BOX_MODEL <const> = ecs.require "vaststars.prototype|selection_box_model"

local create_selection_box = ecs.require "selection_box"
local global = require "global"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"

local mt = {}; mt.__index = mt

function mt:on_position_change(building_srt, dir)
    self.selection_box:set_position(building_srt.t)
    self.selection_box:set_wh(iprototype.rotate_area(self.typeobject.area, dir))
end

function mt:remove()
    self.selection_box:remove()
end

local object_id

local function remove()
    if not object_id then
        return
    end
    local building = assert(global.buildings[object_id])
    assert(building.transfer_source_box)
    building.transfer_source_box:remove()
    building.transfer_source_box = nil

    object_id = nil
end

local function create(id)
    if object_id then
        remove()
    end

    local object = assert(objects:get(id))
    local typeobject = iprototype.queryByName(object.prototype_name)
    local building = global.buildings[object.id]
    assert(building.transfer_source_box == nil)

    local selection_box = create_selection_box(SELECTION_BOX_MODEL,
        object.srt.t, COLOR.TRANSFER_SOURCE, iprototype.rotate_area(typeobject.area, object.dir)
    )
    building.transfer_source_box = setmetatable({selection_box = selection_box, typeobject = typeobject}, mt)

    object_id = id
end

return {
    create = create,
    remove = remove,
}