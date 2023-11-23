return {
    -- 采矿建筑仅保留获取
    ["采矿机I"] = {
        "set_transfer_source",
        "transfer_source",
        "teardown",
    },
    ["采矿机II"] = {
        "set_transfer_source",
        "transfer_source",
        "teardown",
    },
    ["采矿机III"] = {
        "set_transfer_source",
        "transfer_source",
        "teardown",
    },

    -- 废墟建筑仅保留获取
    ["机身残骸"] = {
        "set_transfer_source",
        "transfer_source",
        "teardown",
    },
    ["机翼残骸"] = {
        "set_transfer_source",
        "transfer_source",
        "teardown",
    },
    ["机头残骸"] = {
        "set_transfer_source",
        "transfer_source",
        "teardown",
    },
    ["机尾残骸"] = {
        "set_transfer_source",
        "transfer_source",
        "teardown",
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
        "set_transfer_source",
        "transfer_source",
        "inventory",
        "transfer",
    },

    --仅保留获取放置移动
    ["建筑物残骸"] = {
        "set_transfer_source",
        "transfer_source",
        "move",
        "transfer",
    },

    -- 只有拆除
    ["蒸汽发电机I"] = {
        "teardown",
    },
    ["蒸汽发电机II"] = {
        "teardown",
    },
    ["风力发电机I"] = {
        "teardown",
    },
    ["换热器I"] = {
        "teardown",
    },
    ["热管1-X型"] = {
        "teardown",
    },
    ["地热井I"] = {
        "teardown",
    },
    ["地热井II"] = {
        "teardown",
    },
    ["地热井III"] = {
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
}