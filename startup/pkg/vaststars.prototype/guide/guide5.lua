local guide2 = {
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
            {"哔哩..恭喜你结束了{/g 自动化教学结束}..哔哩..(高兴)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            pop_chapter = {"祝贺","教学完成"},
            task = {
                "自动化教学结束",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "自动化教学",
        },
	},
   
}

return guide2