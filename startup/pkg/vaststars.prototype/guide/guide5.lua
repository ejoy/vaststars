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
            "采矿机规划",
        },
	},
   
}

return guide5