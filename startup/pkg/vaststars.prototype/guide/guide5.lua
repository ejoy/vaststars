local guide5 = {
	{
        name = "",
		narrative = {
            {"哔哩..欢迎进入{/g 自动化教学}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            pop_chapter = {"教学","自动化搭建"},
            task = {
                "自动化教学",
            },
            guide_progress = 10,
        },
        prerequisites = {},
	},

	{
        name = "",
		narrative = {
            {"哔哩..从{/color:4bd0ff 废墟堆}里拾取有用物资", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "拾取物资1",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "自动化教学",
        },
	},

	{
        name = "",
		narrative = {
            {"哔哩..利用获得{/color:4bd0ff 砖石公路}修复断开道路，使得物流网络道路通畅。", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "修复道路",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "拾取物资1",
        },
	},

	{
        name = "",
		narrative = {
            {"哔哩..通往铝矿的道路通畅了，我们再对{/color:4bd0ff 铝矿石}进行发货设置", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "铝矿石发货设置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "修复道路",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..在路网里添加足够的{/g 运输车辆}，让整个基地的物流开始正常运转。", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "运输车派遣",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "铝矿石发货设置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..前往组装机开始生产{/g 地质科技包}，确保{/color:4bd0ff 碎石}、{/color:4bd0ff 铁矿石}、{/color:4bd0ff 铝矿石}可以正常供应", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "地质科技包量产",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "运输车派遣",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..向{/color:4bd0ff 科研中心}提供科技包可以进行科学研究", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "气候研究",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "地质科技包量产",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..让我们量产新解锁的{/g 气候科技包}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "气候科技包量产",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "气候研究",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..恭喜你结束了{/g 自动化教学结束}..哔哩..(高兴)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            pop_chapter = {"祝贺","教学完成"},
            task = {
                "自动化结束",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "自动化科技",
        },
	},
   
}

return guide5