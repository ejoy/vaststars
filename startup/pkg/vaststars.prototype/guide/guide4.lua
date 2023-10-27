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