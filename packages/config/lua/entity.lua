local t = {}
local prototype = function(pt, i)
    if t[pt] then
        error(pt)
    end
    t[pt] = i
end

prototype ("铁制电线杆", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("蒸汽发电机1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("风力发电机1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("太阳能板1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("蓄电池1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("电解厂1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("水电站1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("蒸馏厂1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("化工厂1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("采矿机1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("组装机1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("熔炼炉1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("粉碎机1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("地下管1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("液罐1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("抽水泵", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("压力泵1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("烟囱1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("排水口1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("空气过滤器1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("砖石公路", {
    prefab = "road/road_O.prefab",
    construct_component = {
        construct_road = true,
        construct_detector = "exclusive",
    },
    component = {
        pickup_show_remove = true,
    },
})

prototype ("小型铁制箱子", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("机器爪1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("物流中心", {
    prefab = "assembling.prefab",
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
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("车站1", {
    prefab = "assembling.prefab",
    construct_component = {
        construct_detector = "roadside",
    },
    component = {
    	set_road_entry = true,
        pickup_show_remove = true,
    },
})

prototype ("管道1-I型", {
    prefab = "pipe/pipe_O.prefab",
    construct_component = {
        construct_pipe = true,
        construct_detector = "exclusive",
    },
    component = {
        pickup_show_remove = true,
    },
})

return t
