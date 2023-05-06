local math3d = require "math3d"

POWER_SUPPLY_AREA = {0.58, 0.88, 0.90, 0.25}          -- 电力范围
CONSTRUCT_VALID = {0.0, 1.0, 0.0, 0.58}               -- 建造底块(合法时)
CONSTRUCT_INVALID = {0.94, 0.0, 0.0, 0.58}            -- 建造底块(非法时)
CONSTRUCT_POWER_VALID = {0.0, 0.78, 0.78, 0.66}       -- 建造底块 & 有导电功能的建筑(合法时)
CONSTRUCT_POWER_INVALID = {0.94, 0.0, 0.0, 0.58}      -- 建造底块 & 有导电功能的建筑(非法时)
CONSTRUCT_NEARBY_BUILDINGS_OUTLINE = math3d.constant("v4", {1.0, 1.0, 1.0, 1})
CONSTRUCT_SELF_OUTLINE = math3d.constant("v4", {0, 1, 0, 1})
DRONE_DEPOT_SUPPLY_AREA_VALID = {1.0, 1.0, 0.0, 0.58} -- 无人机物流范围(合法时) -- 自身
DRONE_DEPOT_SUPPLY_AREA_2 = {1.0, 1.0, 0.0, 0.58}     -- 无人机物流范围(其它无人机) 