local t = {}
local prototype = function(pt, i)
    if t[pt] then
        error(pt)
    end
    t[pt] = i
end

prototype ("指挥中心", {
    prefab = "prefabs/headquater-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("铁制电线杆", {
    prefab = "prefabs/assembling-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("蒸汽发电机1", {
    prefab = "prefabs/assembling-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("风力发电机1", {
    prefab = "prefabs/wind-turbine-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("太阳能板1", {
    prefab = "prefabs/assembling-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("蓄电池1", {
    prefab = "prefabs/small-chest.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("电解厂1", {
    prefab = "prefabs/assembling-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("水电站1", {
    prefab = "prefabs/assembling-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("蒸馏厂1", {
    prefab = "prefabs/distillery-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("化工厂1", {
    prefab = "prefabs/distillery-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("采矿机1", {
    prefab = "prefabs/assembling-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("组装机1", {
    prefab = "prefabs/assembling-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("熔炼炉1", {
    prefab = "prefabs/furnace-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("粉碎机1", {
    prefab = "prefabs/assembling-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("地下管1", {
    prefab = "prefabs/pipe/pipe_J.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("液罐1", {
    prefab = "prefabs/storage-tank-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("抽水泵", {
    prefab = "prefabs/offshore-pump-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("压力泵1", {
    prefab = "prefabs/pump-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("烟囱1", {
    prefab = "prefabs/chimney-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("排水口1", {
    prefab = "prefabs/outfall-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("空气过滤器1", {
    prefab = "prefabs/chimney-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("砖石公路", {
    prefab = "prefabs/road/road_O.prefab",
    construct_component = {
        construct_road = true,
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("小型铁制箱子", {
    prefab = "prefabs/small-chest.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("机器爪1", {
    prefab = "prefabs/goods-station-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("物流中心", {
    prefab = "prefabs/logistics-center-1.prefab",
    construct_component = {
        construct_detector = {"roadside"},
    },
    component = {
    	set_road_entry = true,
        station = true,
    },
})

prototype ("科技中心1", {
    prefab = "prefabs/lab-1.prefab",
    construct_component = {
        construct_detector = {"exclusive"},
    },
    component = {
    },
})

prototype ("车站1", {
    prefab = "prefabs/goods-station-1.prefab",
    construct_component = {
        construct_detector = {"roadside"},
    },
    component = {
    	set_road_entry = true,
    },
})

prototype ("管道1-I型", {
    prefab = "prefabs/pipe/pipe_I.prefab",
    construct_component = {
        construct_pipe = true,
        construct_detector = {"exclusive"},
    },
    component = {},
})


prototype ("管道1-L型", {
    prefab = "prefabs/pipe/pipe_L.prefab",
    construct_component = {
        construct_pipe = true,
        construct_detector = {"exclusive"},
    },
    component = {},
})

prototype ("管道1-O型", {
    prefab = "prefabs/pipe/pipe_O.prefab",
    construct_component = {
        construct_pipe = true,
        construct_detector = {"exclusive"},
    },
    component = {},
})

prototype ("管道1-T型", {
    prefab = "prefabs/pipe/pipe_T.prefab",
    construct_component = {
        construct_pipe = true,
        construct_detector = {"exclusive"},
    },
    component = {},
})

prototype ("管道1-U型", {
    prefab = "prefabs/pipe/pipe_U.prefab",
    construct_component = {
        construct_pipe = true,
        construct_detector = {"exclusive"},
    },
    component = {},
})

prototype ("管道1-X型", {
    prefab = "prefabs/pipe/pipe_X.prefab",
    construct_component = {
        construct_pipe = true,
        construct_detector = {"exclusive"},
    },
    component = {},
})


return t
