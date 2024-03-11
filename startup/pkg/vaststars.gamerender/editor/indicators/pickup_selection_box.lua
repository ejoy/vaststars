local ecs = ...
local world = ecs.world
local w = world.w

local COLOR <const> = ecs.require "vaststars.prototype|color"
local SELECTION_BOX_MODEL <const> = ecs.require "vaststars.prototype|selection_box_model"

local iprototype = require "gameplay.interface.prototype"
local create_selection_box = ecs.require "selection_box"

local mt = {}
mt.__index = mt

function mt:on_status_change(valid)
    local color = valid and COLOR.CONSTRUCT_OUTLINE_SELF_VALID or COLOR.CONSTRUCT_OUTLINE_SELF_INVALID
    self.selection_box:set_color_transition(color, 400)
end

function mt:on_position_change(building_srt, dir)
    self.selection_box:set_wh(iprototype.rotate_area(self.area, dir))
    self.selection_box:set_position(building_srt.t)
end

function mt:remove()
    self.selection_box:remove()
end

return function (position, area, dir, valid)
    local self = setmetatable({}, mt)
    local color = valid and COLOR.CONSTRUCT_OUTLINE_SELF_VALID or COLOR.CONSTRUCT_OUTLINE_SELF_INVALID

    self.area = area
    self.selection_box = create_selection_box(SELECTION_BOX_MODEL,
        position, color, iprototype.rotate_area(area, dir)
    )
    return self
end
