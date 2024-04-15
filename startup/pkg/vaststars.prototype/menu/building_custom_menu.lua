-- "remove_lorry",             删除汽车
-- "move",                     移动建筑
-- "lorry_factory_inc_lorry",  派发汽车
-- "set_item",                 设置物品
-- "set_recipe",               设置配方
-- "copy",                     拷贝建筑
-- "inventory",                进入背包
-- "teardown",                 删除建筑
-- "building_to_backpack",
-- "backpack_to_building",
return {
    -- 采矿建筑仅保留获取
    ["采矿机I"] = {
        "teardown",
    },
    ["采矿机II"] = {
        "teardown",
    },
    ["采矿机III"] = {
        "teardown",
    },
    ["轻型采矿机"] = {
        "teardown",
    },
    -- 废墟建筑仅保留获取
    ["机身残骸"] = {
        "show_item_list",
        "teardown",
    },
    ["机翼残骸"] = {
        "show_item_list",
        "teardown",
    },
    ["机头残骸"] = {
        "show_item_list",
        "teardown",
    },
    ["机尾残骸"] = {
        "show_item_list",
        "teardown",
    },
    ["建筑物残骸 1x1"] = {
    },
    ["建筑物残骸 1x2"] = {
    },
    ["建筑物残骸 2x1"] = {
    },
    ["建筑物残骸 2x2"] = {
    },
    ["建筑物残骸 3x3"] = {
    },
    ["建筑物残骸 3x5"] = {
    },
    ["建筑物残骸 4x2"] = {
    },
    ["建筑物残骸 4x4"] = {
    },
    ["建筑物残骸 4x6"] = {
    },
    ["建筑物残骸 5x3"] = {
    },
    ["建筑物残骸 5x5"] = {
    },
    ["建筑物残骸 6x4"] = {
    },
    ["建筑物残骸 6x6"] = {
    },
    -- 液体输入/输出建筑仅保留移动和复制
    ["空气过滤器I"] = {
        "move",
        "copy",
        "teardown",
    },
    ["空气过滤器II"] = {
        "move",
        "copy",
        "teardown",
    },
    ["空气过滤器III"] = {
        "move",
        "copy",
        "teardown",
    },
    ["地下水挖掘机I"] = {
        "move",
        "copy",
        "teardown",
    },
    ["地下水挖掘机II"] = {
        "move",
        "copy",
        "teardown",
    },
    ["无人机平台I"] = {
        "move",
        "copy",
        "teardown",
    },
    ["无人机平台II"] = {
        "move",
        "copy",
        "teardown",
    },
    ["无人机平台III"] = {
        "move",
        "copy",
        "teardown",
    },
    ["蒸汽发电机I"] = {
        "move",
        "copy",
        "teardown",
    },
    ["蒸汽发电机II"] = {
        "move",
        "copy",
        "teardown",
    },
    ["蒸汽发电机III"] = {
        "move",
        "copy",
        "teardown",
    },
    ["风力发电机I"] = {
        "move",
        "copy",
        "teardown",
    },
    ["轻型风力发电机"] = {
        "move",
        "copy",
        "teardown",
    },
    ["换热器I"] = {
        "move",
        "copy",
        "teardown",
    },
    ["停车站"] = {
        "move",
        "copy",
        "teardown",
    },
    ["太阳能板I"] = {
        "move",
        "copy",
        "teardown",
    },
    ["太阳能板II"] = {
        "move",
        "copy",
        "teardown",
    },
    ["太阳能板III"] = {
        "move",
        "copy",
        "teardown",
    },
    ["轻型太阳能板"] = {
        "move",
        "copy",
        "teardown",
    },
    ["蓄电池I"] = {
        "move",
        "copy",
        "teardown",
    },
    ["蓄电池II"] = {
        "move",
        "copy",
        "teardown",
    },
    ["蓄电池III"] = {
        "move",
        "copy",
        "teardown",
    },
    ["烟囱I"] = {
        "move",
        "copy",
        "teardown",
    },
    ["烟囱II"] = {
        "move",
        "copy",
        "teardown",
    },
    ["排水口I"] = {
        "move",
        "copy",
        "teardown",
    },
    ["排水口II"] = {
        "move",
        "copy",
        "teardown",
    },
    ["液罐I"] = {
        "move",
        "copy",
        "teardown",
    },
    ["液罐II"] = {
        "move",
        "copy",
        "teardown",
    },
    ["液罐III"] = {
        "move",
        "copy",
        "teardown",
    },
    ["地热井I"] = {
        "move",
        "copy",
        "teardown",
    },
    ["地热井II"] = {
        "move",
        "copy",
        "teardown",
    },
    ["地热井III"] = {
        "move",
        "copy",
        "teardown",
    },
    -- 公路仅保留复制和拆除
    ["砖石公路-I型"] = {
        "copy",
        "teardown",
    },
    ["砖石公路-L型"] = {
        "copy",
        "teardown",
    },
    ["砖石公路-T型"] = {
        "copy",
        "teardown",
    },
    ["砖石公路-O型"] = {
        "copy",
        "teardown",
    },
    ["砖石公路-U型"] = {
        "copy",
        "teardown",
    },
    ["砖石公路-X型"] = {
        "copy",
        "teardown",
    },

    -- 运输车辆仅保留删除车辆
    ["运输车辆I"] = {
        "remove_lorry",
    },

    -- 仅保留获取放置背包
    ["指挥中心"] = {
        "inventory",
    },

    -- 只有拆除
    ["热管1-X型"] = {
        "teardown",
    },
    ["压力泵I"] = {
        "teardown",
    },
    ["管道1-I型"] = {
        "teardown",
    },
    ["管道1-L型"] = {
        "teardown",
    },
    ["管道1-T型"] = {
        "teardown",
    },
    ["管道1-X型"] = {
        "teardown",
    },
    ["管道1-O型"] = {
        "teardown",
    },
    ["管道1-U型"] = {
        "teardown",
    },
    ["地下管1-JU型"] = {
        "teardown",
    },
    ["地下管1-JI型"] = {
        "teardown",
    },
    ["地下管2-JU型"] = {
        "teardown",
    },
    ["地下管2-JI型"] = {
        "teardown",
    },

-----------物流中心类型---------
    ["物流中心"] = {
        "move",
        "lorry_factory_inc_lorry",
        "copy",
        "teardown",
    },
-----------科研中心类型---------
    ["科研中心I"] = {
        "move",
        "copy",
        "teardown",
    },
    ["科研中心II"] = {
        "move",
        "copy",
        "teardown",
    },
    ["科研中心III"] = {
        "move",
        "copy",
        "teardown",
    },
    ["地质科研中心"] = {
        "move",
        "copy",
        "teardown",
    },
-----------固体组装机类型---------
    ["组装机I"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["组装机II"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["组装机III"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["熔炼炉I"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["熔炼炉II"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["熔炼炉III"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["粉碎机I"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["粉碎机II"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["粉碎机III"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ----------液体组装机类型-------------
    ["化工厂I"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["化工厂II"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["化工厂III"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["蒸馏厂I"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["蒸馏厂II"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["蒸馏厂III"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["浮选器I"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },
    ["特殊浮选器"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },
    ["浮选器II"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["浮选器III"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["电解厂I"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },
    ["电解厂II"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["电解厂III"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },
    ["水电站I"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },
    ["水电站II"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },

    ["水电站III"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },
    ["锅炉I"] = {
        "move",
        "set_recipe",
        "copy",
        "teardown",
    },
    ----------仓库类型-------------
    ["仓库I"] = {
        "move",
        "set_item",
        "copy",
        "teardown",
        "building_to_backpack",
        "backpack_to_building",
    },

    ["仓库II"] = {
        "move",
        "set_item",
        "copy",
        "teardown",
        "building_to_backpack",
        "backpack_to_building",
    },

    ["仓库III"] = {
        "move",
        "set_item",
        "copy",
        "teardown",
        "building_to_backpack",
        "backpack_to_building",
    },
    ----------物流站类型-------------
    ["物流站"] = {
        "move",
        "set_item",
        "copy",
        "teardown",
    },
}