local entities = {
    {
        prototype_name = "指挥中心",
        dir = "N",
        x = 126,
        y = 120,
    },
    {
        prototype_name = "机身残骸",
        dir = "N",
        items = {
            {"电线杆框架",10},
            {"熔炼炉框架",2},
            {"组装机框架",2},
            {"空气过滤器框架",4},
            {"水电站框架",2},
            {"无人机仓库框架",5},
            {"送货车站框架",2},
            {"收货车站框架",2},
            {"熔炼炉框架",1},
            {"采矿机框架",2},
        },
        x = 107,
        y = 134,
    },
    {
        prototype_name = "机尾残骸",
        dir = "S",
        items = {
            {"采矿机框架",1},
            {"组装机框架",2},
            {"科研中心框架",1},
        },
        x = 110,
        y = 120,
    },
    
    {
        prototype_name = "建材箱",
        dir = "N",
        x = 114,
        y = 124,
        items = {
            {"采矿机I",1},
        },
    },

    {
        prototype_name = "建材箱",
        dir = "N",
        x = 127,
        y = 116,
        items = {
            {"铁制电线杆",10},
        },
    },

    {
        prototype_name = "建材箱",
        dir = "N",
        x = 130,
        y = 116,
        items = {
            {"科研中心I",1},
        },
    },

    {
        prototype_name = "建材箱",
        dir = "N",
        x = 127,
        y = 128,
        items = {
            {"无人机仓库",4},
        },
    },

    {
        prototype_name = "建材箱",
        dir = "N",
        x = 130,
        y = 128,
        items = {
            {"组装机I",2},
        },
    },
    {
        prototype_name = "建材箱",
        dir = "N",
        x = 134,
        y = 120,
        items = {
            {"建造中心",1},
        },
    },
    {
        prototype_name = "建材箱",
        dir = "N",
        x = 114,
        y = 118,
        items = {
            {"风力发电机I",1},
        },
    },
    -- {
    --     prototype_name = "建造中心",
    --     dir = "N",
    --     x = 119,
    --     y = 120,
    -- },
    {
        prototype_name = "机翼残骸",
        dir = "S",
        items = {
            {"组装机框架",2},
            {"熔炼炉框架",1},
            {"运输车框架",4},
            {"电线杆框架",5},
            {"太阳能板框架",6},
        },
        x = 133,
        y = 122,
    },
    {
        prototype_name = "机头残骸",
        dir = "W",
        items = {
            {"蓄电池框架",15},
	        {"地下水挖掘机框架",4},
	        {"电解厂框架",1},
	        {"化工厂框架",3},
            {"无人机仓库框架",4},
        },
        x = 125,
        y = 108,
    },
    -- {
    --     prototype_name = "组装机I",
    --     dir = "N",
    --     x = 133,
    --     y = 117,
    -- },
    -- {
    --     prototype_name = "熔炼炉I",
    --     dir = "N",
    --     x = 140,
    --     y = 126,
    -- },
}

local road = {
}

return {
    entities = entities,
    road = road,
}