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
            {"哔哩..现在让我们前往{/g 电解厂}开始为{/color:4bd0ff 电解卤水}做准备", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "电解厂配方设置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "液罐获取",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..放置一台{/g 地下水挖掘机}连接{/color:4bd0ff 电解厂}的{/g 对应液口}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "连接电解厂",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "电解厂配方设置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..电解卤水会产生一些暂时无用的气体——例如{/color:4bd0ff 氯气}，{/g 烟囱}可以将其排放干净", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "连接烟囱",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "连接电解厂",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..我们需要{/g 液罐}来收集重要气体原料——{/color:4bd0ff 氢气}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "氢气存储",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "连接烟囱",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..我们接着需要设置{/color:4bd0ff 蒸馏厂}的生产目标", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "蒸馏厂配方设置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "氢气存储",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..{/g 空气净化器}释放出来的{/color:4bd0ff 空气}是{/color:4bd0ff 蒸馏厂}加工的主要原料", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "连接空气净化器",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "蒸馏厂配方设置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..请为蒸馏厂生产出的{/g 二氧化碳}提供足够的存储", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "二氧化碳存储",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "连接空气净化器",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..附带生产出的{/color:4bd0ff 氮气}目前没有用途，请用{/g 烟囱}将其排放掉", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "氮气清除",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "二氧化碳存储",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..原料气体{/color:4bd0ff 氢气}和{/color:4bd0ff 二氧化碳}已经就绪，现在可以准备{/g 化工厂}生产了", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "化工厂配方设置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "氮气清除",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..将原料气体{/color:4bd0ff 氢气}和{/color:4bd0ff 二氧化碳}通入到{/g 化工厂对应液口}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "化工厂原料添加",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "化工厂配方设置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..请生产300个单位{/g 甲烷}完成最后的目标", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "甲烷生产",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "化工厂原料添加",
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
            "甲烷生产",
        },
	},
}

return guide2