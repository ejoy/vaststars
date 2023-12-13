local guide2 = {
	{
        name = "",
		narrative = {
            {"哔哩..欢迎进入{/g 物流教学}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
            {"哔哩..检查地面上的{/color:4bd0ff 废墟堆},拾取残余{/g 物资}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            pop_chapter = {"教学","物流搭建"},
            task = {
                "废墟搜索",
            },
            guide_progress = 1,
        },
        prerequisites = {},
	},

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..检查地面上的{/color:4bd0ff 废墟堆},拾取残余{/g 物资}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
    --     },
    --     narrative_end = {
    --         task = {
    --             "废墟搜索",
    --         },
    --         guide_progress = 10,
    --     },
    --     prerequisites = {
    --         "物流教学",
    --     },
	-- },

    {
        name = "",
		narrative = {
            {"哔哩..将获得{/color:4bd0ff 建筑物资}放入{/g 指挥中心}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "放置物资",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "废墟搜索",
        },
	},

    {
        name = "",
        narrative = {
            {"哔哩..我们从废墟中获得了许多{/g 砖石公路},这些物资是{/color:4bd0ff 搭建公路}的重要材料..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
            {"哔哩..残缺的公路阻碍正常物流,用{/g 砖石公路}修补{/color:4bd0ff 2处断开公路}..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "道路维修",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "放置物资",
        },
	},

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..空闲的{/color:4bd0ff 运输车辆}必须停靠在{/g 停车站}..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
    --         {"哔哩..让我们先在路边修建一座{/g 停车站}..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
    --     },
    --     narrative_end = {
    --         task = {
    --             "停车站放置",
    --         },
    --         guide_progress = 10,
    --     },
    --     prerequisites = {
    --         "道路维修",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..下个重要物流设施是{/g 物流站},其中可以设置{/color:4bd0ff 出货}和{/color:4bd0ff 收货}..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
    --         {"哔哩..物流网络中至少需要{/g 2个物流站}才可以进行运转..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
    --         {"哔哩..让我们尝试将矿区边的{/color:4bd0ff 物流站}设置为{/g 出货}吧..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
    --     },
    --     narrative_end = {
    --         task = {
    --             "物流站放置",
    --         },
    --         guide_progress = 10,
    --     },
    --     prerequisites = {
    --         "停车站放置",
    --     },
	-- },

    {
        name = "",
		narrative = {
            {"哔哩..下个重要物流设施是{/g 物流站},其中可以设置{/color:4bd0ff 发货}和{/color:4bd0ff 收货}..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
            {"哔哩..让我们尝试将矿区边的{/color:4bd0ff 物流站}设置{/g 发货类型}吧..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "物流站发货设置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "道路维修",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩.. 让我们在把组装机边的{/color:4bd0ff 物流站}设置{/g 收货类型}吧..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
            {"哔哩..当两个物流站的{/color:4bd0ff 发货类型}和{/color:4bd0ff 收货类型}相同时,运输车就会开始两地运输..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "物流站收货设置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "物流站发货设置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩.. 让我们前往{/color:4bd0ff 物流中心}派遣{/g 运输车}吧..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "派遣运输车",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "物流站收货设置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩.. 现在{/color:4bd0ff 运输车}开始运输了，让运输车运送原料生产一些{/g 石砖}吧..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "石砖大生产",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "派遣运输车",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩.. 在{/color:4bd0ff 组装机}里用{/color:4bd0ff 石砖}生产一些{/g 砖石公路}吧..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "更多公路",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "石砖大生产",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩.. 下面我们使用{/color:4bd0ff 熔炼炉}炼制一些{/g 铁板}..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "铁板大生产",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "更多公路",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩.. 我们可以用{/color:4bd0ff 铁板}可以生产更多的{/g 运输车辆}..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "制造运输车",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "铁板大生产",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩.. 前往{/color:4bd0ff 物流中心}派遣更多的{/g 运输车辆}..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "更多运输车",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "制造运输车",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩.. 有了{/color:4bd0ff 石砖}和{/color:4bd0ff 铁板}这些加工材料，允许我们生产更多{/g 采矿机}..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "制造采矿机",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "更多运输车",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩.. 有了新制造的{/color:4bd0ff 采矿机}我们就可以开采{/g 铝矿}了..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "铝矿石开采",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "制造采矿机",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩.. 现在可以开采{/color:4bd0ff 石矿}、{/color:4bd0ff 铁矿}和{/color:4bd0ff 铝矿},我们就可以制造{/g 地质科技包}了..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "科技包大生产",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "铝矿石开采",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩.. 让我们完成最后{/color:4bd0ff 科技研究}..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "完成科技研究",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "科技包大生产",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..恭喜你结束了{/g 物流教学}..哔哩..(高兴)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            pop_chapter = {"祝贺","教学完成"},
            task = {
                "物流教学结束",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "完成科技研究",
        },
	},
}

return guide2