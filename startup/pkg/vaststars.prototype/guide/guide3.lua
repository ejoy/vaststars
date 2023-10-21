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

	
}

return guide2