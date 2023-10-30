local guide2 = {
	{
        name = "",
		narrative = {
            {"哔哩..欢迎进入{/g 流体教学}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            pop_chapter = {"教学","液网搭建"},
            task = {
                "流体教学",
            },
            guide_progress = 10,
        },
        prerequisites = {},
	},

    {
        name = "",
		narrative = {
            {"哔哩..先从{/color:4bd0ff 仓库}里获取一些成品{/g 管道}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "管道接收",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "流体教学",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..用刚才获得的{/g 管道}连接{/color:4bd0ff 地下水挖掘机}和{/color:4bd0ff 液罐}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "连接液罐",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "管道接收",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..我们现在前往{/color:4bd0ff 组装机}设置生产{/g 地下管配方}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "地下管生产设置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "连接液罐",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..从设置配方的{/color:4bd0ff 组装机}里拿去生产完毕的{/g 地下管}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "获取地下管",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "地下管生产设置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..{/g 地下管}从地下搭设进而可以绕过地面上的{/color:4bd0ff 障碍物}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "地下管连接",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "获取地下管",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..我们成功用{/color:4bd0ff 地下管}连接了{/color:4bd0ff 水电站},让我们开始生产{/g 气候科技包}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "气候科技包生产",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "地下管连接",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..拾取{/color:4bd0ff 废墟}里的物资，放置{/g 地下水挖掘机}和{/g 空气过滤器}让第二个水电站开始运转吧", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "启动第二水电站",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "气候科技包生产",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..两个{/color:4bd0ff 水电站}开始运转，让我们生产足够{/g 气候科技包}进行科学研究", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "液罐制造工艺",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "启动第二水电站",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..使用{/color:4bd0ff 组装机}生产刚刚研制出来{/g 液罐}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "液罐获取",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "液罐制造工艺",
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
                "流体教学结束",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "完成流体研究",
        },
	},
}

return guide2