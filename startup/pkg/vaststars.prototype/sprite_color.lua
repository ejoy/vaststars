local math3d = require "math3d"

POWER_SUPPLY_AREA = {0.58, 0.88, 0.90, 0.25}          -- 电力范围
CONSTRUCT_POWER_VALID = {0.0, 0.78, 0.78, 0.66}       -- 建造底块 & 有导电功能的建筑(合法时)
CONSTRUCT_POWER_INVALID = {0.94, 0.0, 0.0, 0.58}      -- 建造底块 & 有导电功能的建筑(非法时)
CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_VALID = {1.0, 1.0, 0.0, 0.58}   -- 无人机物流范围(合法时) -- 自身
CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_INVALID = {1.0, 1.0, 0.0, 0.58} -- 无人机物流范围(非法时) -- 自身
CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_OTHER = {1.0, 1.0, 0.0, 0.58}        -- 无人机物流范围(其它无人机) 
CONSTRUCT_OUTLINE_NEARBY_BUILDINGS = math3d.constant("v4", {1.0, 1.0, 1.0, 1})
CONSTRUCT_OUTLINE_SELF_VALID = math3d.constant("v4", {0, 1, 0, 1})   -- 建造时, 自身的外框(合法时)
CONSTRUCT_OUTLINE_SELF_INVALID = math3d.constant("v4", {1, 0, 0, 1}) -- 建造时, 自身的外框(非法时)