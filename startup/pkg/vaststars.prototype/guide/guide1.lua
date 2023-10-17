local guide1 = {
	{
        name = "",
		narrative = {
            {"哔哩..让我们正式进入{/color:4bd0ff 采矿教学}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            pop_chapter = {"教学","开采矿物"},
            task = {
                "采矿教学",
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
                "拾取物资",
            },
            guide_progress = 2,
        },
        prerequisites = {
            "采矿教学",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..在三处矿点上各放置1台{/g 采矿机}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "采矿机放置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "拾取物资",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..放置{/g 铁制电线杆}连接附近{/color:4bd0ff 风力发电机}并让采矿机处于{/color:4bd0ff 电线杆覆盖范围}内..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "电网搭建",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "采矿机放置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..放置1座{/g 仓库}在{/g 组装机}附近，确保仓库放置在{/color:4bd0ff 无人机平台范围}内..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "仓库放置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "电网搭建",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..仓库分别设置收货{/g 碎石}、{/g 铁矿石}、{/g 铝矿石}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "收货设置1",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "仓库放置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..在仓库里放置{/g 4个碎石}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "仓库存储矿石",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "收货设置1",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..点击{/g 组装机}并设置配方{/g 地质科技包1}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "组装机配方设置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "仓库存储矿石",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..点击{/g 仓库}并添加收货类型{/g 地质科技包}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "收货设置2",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "组装机配方设置",
        },
	},
    
    {
        name = "",
		narrative = {
            {"哔哩..往仓库里放置{/g 矿物}让组装机生产足够的{/g 地质科技包}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "科技包生产",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "收货设置2",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..恭喜你结束了{/g 挖矿教学}..哔哩..(高兴)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            pop_chapter = {"祝贺","结束教学"},
            task = {
                "挖矿教学结束",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "科技包生产",
        },
	},
}

return guide1