return {
    POWER_SUPPLY_AREA = {r = 150, g = 226, b = 232, a = 180},                  -- 电力范围
    CONSTRUCT_VALID = {r = 0, g = 255, b = 0, a = 220},                        -- 建造底块(合法时)
    CONSTRUCT_INVALID = {r = 200, g = 0, b = 0, a = 160},                      -- 建造底块(非法时)
    CONSTRUCT_POWER_VALID = {r = 0, g = 200, b = 200, a = 150},                  -- 建造底块 & 有导电功能的建筑(合法时)
    CONSTRUCT_POWER_INVALID = {r = 240, g = 0, b = 0, a = 235},                -- 建造底块 & 有导电功能的建筑(非法时)
    DRONE_DEPOT_SUPPLY_AREA_VALID = {r = 255, g = 255, b = 0, a = 150},     -- 无人机物流范围(合法时) -- 自身
    DRONE_DEPOT_SUPPLY_AREA_2 = {r = 255, g = 255, b = 0, a = 150},              -- 无人机物流范围(其它无人机) 
}