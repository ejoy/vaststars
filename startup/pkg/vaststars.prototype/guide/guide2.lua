local guide2 = {
	{
        name = "",
		narrative = {
            {"哔哩..欢迎进入{/g 电网教学}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
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
            {"哔哩..放置{/color:4bd0ff 采矿机}准备开采矿物..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "矿区搭建",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "检查废墟",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..所有{/color:4bd0ff 采矿机}处于{/r 缺电状态},这不是我们希望的..哔哩..(担忧)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
            {"哔哩..请放置1台{/g 轻型风力发电机}给矿区{/color:4bd0ff 供电}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "风力发电机放置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "矿区搭建",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..{/g 采矿机}都顺利通电工作了..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},  
            {"哔哩..现在设置{/color:4bd0ff 仓库}收货{/g 碎石}、{/g 铁矿石}、{/g 铝矿石}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "收集矿石",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "风力发电机放置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..{/color:4bd0ff 组装机}设置配方{/g 轻质石砖}进行生产..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "生产设置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "收集矿石",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..设置{/color:4bd0ff 新仓库}收货{/g 碎石}、{/g 铁矿石}、{/g 铝矿石}、{/g 轻质石砖}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "新仓库设置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "生产设置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..往{/color:4bd0ff 新仓库}转放{/color:4bd0ff 10个}{/g 铝矿石}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "仓库互转",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "新仓库设置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..检查新{/color:4bd0ff 废墟}并拾取{/g 太阳能板}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "太阳能板获取",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "生产轻质石砖",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..放置{/color:4bd0ff 2个}{/g 轻型太阳能板}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "太阳能板铺设",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "太阳能板获取",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..然而{/g 轻型太阳能板}只能在{/color:4bd0ff 白天}工作,到了{/r 夜晚}则无法发电..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
            {"哔哩..我们需要放置{/g 蓄电池}来维持{/r 夜晚}的供电..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "蓄电池铺设",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "太阳能板铺设",
        },
	},

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..让我们开始研究制造{/color:4bd0ff 轻型太阳能板}的科技..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
    --         {"哔哩..只要给{/color:4bd0ff 科研中心}提供{/g 地质科技包},科研就会开展..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
    --     },
    --     narrative_end = {
    --         task = {
    --             "太阳能制造技术",
    --         },
    --         guide_progress = 10,
    --     },
    --     prerequisites = {
    --         "蓄电池铺设",
    --     },
	-- },

    {
        name = "",
		narrative = {
            {"哔哩..让我们寻找{/color:4bd0ff 废墟}中的其他发电设备..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "发电机获取",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "太阳能发电",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..恭喜你结束了{/g 电网教学}..哔哩..(高兴)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            pop_chapter = {"祝贺","教学完成"},
            task = {
                "电网教学结束",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "启动科技研究",
        },
	},
}

return guide2