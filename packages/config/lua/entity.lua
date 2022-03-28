local t = {}
local prototype = function(pt, i)
    if t[pt] then
        error(pt)
    end
    t[pt] = i
end

prototype ("指挥中心", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("铁制电线杆", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("蒸汽发电机1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("风力发电机1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("太阳能板1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("蓄电池1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("电解厂1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("水电站1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("蒸馏厂1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("化工厂1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("采矿机1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("组装机1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("熔炼炉1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("粉碎机1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("地下管1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("液罐1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("抽水泵", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("压力泵1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("烟囱1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("排水口1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("空气过滤器1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("砖石公路", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("小型铁制箱子", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("机器爪1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("物流中心", {
    construct_detector = {"roadside"},
    component = {
        station = true,
    },
})

prototype ("科技中心1", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("车站1", {
    construct_detector = {"roadside"},
    component = {},
})

prototype ("管道1-I型", {
    construct_detector = {"exclusive"},
    component = {},
})


prototype ("管道1-L型", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("管道1-O型", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("管道1-T型", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("管道1-U型", {
    construct_detector = {"exclusive"},
    component = {},
})

prototype ("管道1-X型", {
    construct_detector = {"exclusive"},
    component = {},
})


return t
