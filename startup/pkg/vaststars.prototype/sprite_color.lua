local math3d = require "math3d"

return {
    CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_VALID = {0.77, 0.35, 0.7, 0.25},   -- 无人机物流范围(合法时) -- 自身
    CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_INVALID = {0.77, 0.35, 0.7, 0.25}, -- 无人机物流范围(非法时) -- 自身
    CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_OTHER = {0.8, 0.8, 0.3, 0.2},        -- 无人机物流范围(其它无人机) 
    CONSTRUCT_OUTLINE_NEARBY_BUILDINGS = math3d.constant("v4", {1.0, 1.0, 1.0, 1}), -- 附近的其它建筑
    CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA = math3d.constant("v4", {1.0, 1.0, 0.0, 1}), -- 附近的其它建筑(无人机物流范围内)
    CONSTRUCT_OUTLINE_FARAWAY_BUILDINGS_INTERSECTION = math3d.constant("v4", {1.0, 0.0, 1.0, 1}), -- 附近相交的其它建筑
    CONSTRUCT_OUTLINE_SELF_VALID = math3d.constant("v4", {0, 1, 0, 1}),   -- 建造时, 自身的外框(合法时)
    CONSTRUCT_OUTLINE_SELF_INVALID = math3d.constant("v4", {1, 0, 0, 1}), -- 建造时, 自身的外框(非法时)
    SELECTED_OUTLINE = math3d.constant("v4", {0, 1, 0, 1}),   -- 选中建筑时, 外框的显示
    MOVE_SELF = math3d.constant("v4", {1, 1, 1, 0.15}),
    WORK_STATE_WORKING = math3d.constant("v4", {0.0, 1.0, 0.0, 1}),
    WORK_STATE_IDLE = math3d.constant("v4", {1.0, 1.0, 0.0, 1}),
    WORK_STATE_NO_POWER = math3d.constant("v4", {1.0, 0.0, 0.0, 1}),
    TRANSFER_SOURCE = math3d.constant("v4", {1.0, 1.0, 0.0, 1}),
    CONSTRUCT_SELF = math3d.constant("v4", {0, 0.85, 1, 0.1}),
    CONSTRUCT_SELF_EMISSIVE = math3d.constant("v4", {0, 0, 1, 0.1}),
    SELECTED = math3d.constant("v4", {0, 1, 0, 1}),
}