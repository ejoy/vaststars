local ecs = ...
local world = ecs.world
local w = world.w

local COLOR <const> = ecs.require "vaststars.prototype|color"

local iprototype = require "gameplay.interface.prototype"
local create_selected_boxes = ecs.require "selected_boxes"

local mt = {}
mt.__index = mt

function mt:on_status_change(valid)
    local color = valid and COLOR.CONSTRUCT_OUTLINE_SELF_VALID or COLOR.CONSTRUCT_OUTLINE_SELF_INVALID
    self.selected_boxes:set_color_transition(color, 400)
end

function mt:on_position_change(building_srt, dir)
    self.selected_boxes:set_wh(iprototype.rotate_area(self.area, dir))
    self.selected_boxes:set_position(building_srt.t)
end

function mt:remove()
    self.selected_boxes:remove()
end

return function (position, area, dir, valid)
    local self = setmetatable({}, mt)
    local color = valid and COLOR.CONSTRUCT_OUTLINE_SELF_VALID or COLOR.CONSTRUCT_OUTLINE_SELF_INVALID

    self.area = area
    self.selected_boxes = create_selected_boxes(
        {
            "/pkg/vaststars.resources/glbs/selected-box-no-animation.glb|mesh.prefab",
            "/pkg/vaststars.resources/glbs/selected-box-no-animation-line.glb|mesh.prefab",
        },
        position, color, iprototype.rotate_area(area, dir)
    )
    return self
end
