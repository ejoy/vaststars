local guide2 = {
	{
        name = "",
		narrative = {
            {"哔哩..让我们正式进入{/color:4bd0ff 电网教学}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            pop_chapter = {"教学","电网搭建"},
            task = {
                "电网教学",
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
                "检查废墟",
            },
            guide_progress = 2,
        },
        prerequisites = {
            "电网教学",
        },
	},

	{
        name = "",
		narrative = {
            {"哔哩..检查地面上的{/color:4bd0ff 废墟堆},拾取残余{/g 物资}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "风力发电机放置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "检查废墟",
        },
	},

}

return guide2