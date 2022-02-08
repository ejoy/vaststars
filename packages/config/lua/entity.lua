local t = {}
local prototype = function(pt, i)
    if t[pt] then
        error(pt)
    end
    t[pt] = i
end

prototype ("铁制电线杆", {
    prefab = "prefabs/assembling-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("蒸汽发电机1", {
    prefab = "prefabs/assembling-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("风力发电机1", {
    prefab = "prefabs/wind-turbine-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("太阳能板1", {
    prefab = "prefabs/assembling-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("蓄电池1", {
    prefab = "prefabs/small-chest.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("电解厂1", {
    prefab = "prefabs/assembling-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("水电站1", {
    prefab = "prefabs/assembling-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("蒸馏厂1", {
    prefab = "prefabs/distillery-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("化工厂1", {
    prefab = "prefabs/distillery-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("采矿机1", {
    prefab = "prefabs/assembling-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("组装机1", {
    prefab = "prefabs/assembling-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("熔炼炉1", {
    prefab = "prefabs/furnace-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("粉碎机1", {
    prefab = "prefabs/assembling-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("地下管1", {
    prefab = "prefabs/assembling-1.prefab",
    construct_component = {
    },
    component = {
    },
})

prototype ("液罐1", {
    prefab = "prefabs/storage-tank-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("抽水泵", {
    prefab = "prefabs/offshore-pump-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("压力泵1", {
    prefab = "prefabs/pump-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("烟囱1", {
    prefab = "prefabs/chimney-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("排水口1", {
    prefab = "prefabs/outfall-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("空气过滤器1", {
    prefab = "prefabs/chimney-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("砖石公路", {
    prefab = "prefabs/road/road_O.prefab",
    construct_component = {
        construct_road = true,
        construct_detector = "exclusive",
    },
    component = {
    },
})

prototype ("小型铁制箱子", {
    prefab = "prefabs/small-chest.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("机器爪1", {
    prefab = "prefabs/goods-station-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("物流中心", {
    prefab = "prefabs/logistics-center-1.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
        station = true,
    },
})

prototype ("科技中心1", {
    prefab = "prefabs/lab-1.prefab",
    construct_component = {
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("车站1", {
    prefab = "prefabs/goods-station-1.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("管道1-I型", {
    prefab = "prefabs/pipe/pipe_O.prefab",
    construct_component = {
        construct_pipe = true,
        construct_detector = "exclusive",
    },
    component = {
    },
})

return t
