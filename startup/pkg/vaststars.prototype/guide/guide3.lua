local guide2 = {
	{
        name = "",
		narrative = {
            {"哔哩..欢迎进入{/g 物流教学}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            pop_chapter = {"教学","物流搭建"},
            task = {
                "物流教学",
            },
            guide_progress = 1,
        },
        prerequisites = {},
	},

    {
        name = "",
		narrative = {
            {"哔哩..检查地面上的{/color:4bd0ff 废墟堆},拾取残余{/g 物资}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "废墟搜索",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "物流教学",
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
            "废墟搜索",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..空闲的{/color:4bd0ff 运输车辆}必须停靠在{/g 停车站}..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
            {"哔哩..让我们先在路边修建一座{/g 停车站}..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "停车站放置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "道路维修",
        },
	},

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
            {"哔哩..让我们尝试将矿区边的{/color:4bd0ff 物流站}设置为{/g 发货}吧..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "物流站发货设置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "停车站放置",
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
            "开启科技研究",
        },
	},
}

return guide2