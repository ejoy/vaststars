local ecs = ...
local world = ecs.world
local w = world.w

local SPRITE_COLOR <const> = ecs.require "vaststars.prototype|sprite_color"

local create_selected_boxes = ecs.require "selected_boxes"
local global = require "global"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"

local mt = {}; mt.__index = mt

function mt:on_position_change(building_srt, dir)
    self.selected_boxes:set_position(building_srt.t)
    self.selected_boxes:set_wh(iprototype.rotate_area(self.typeobject.area, dir))
end

function mt:remove()
    self.selected_boxes:remove()
end

local object_id

local function remove()
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

    local selected_boxes = create_selected_boxes({
            "/pkg/vaststars.resources/glbs/selected-box-no-animation.glb|mesh.prefab",
            "/pkg/vaststars.resources/glbs/selected-box-no-animation-line.glb|mesh.prefab",
        },
        object.srt.t, SPRITE_COLOR.TRANSFER_SOURCE, iprototype.rotate_area(typeobject.area, object.dir)
    )
    building.transfer_source_box = setmetatable({selected_boxes = selected_boxes, typeobject = typeobject}, mt)

    object_id = id
end

return {
    create = create,
    remove = remove,
}