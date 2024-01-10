local guide2 = {
	{
        name = "",
		narrative = {
            {"哔哩..欢迎进入{/g 电网教学}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
            {"哔哩..检查地面上的{/color:4bd0ff 废墟堆},拾取残余{/g 物资}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            pop_chapter = {"/pkg/vaststars.resources/ui/chapter_pop.html", {main_text = "教学", sub_text = "电网搭建"}},
            task = {
                "检查废墟",
            },
            guide_progress = 1,
        },
        prerequisites = {},
	},

	-- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..检查地面上的{/color:4bd0ff 废墟堆},拾取残余{/g 物资}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
    --     },
    --     narrative_end = {
    --         task = {
    --             "检查废墟",
    --         },
    --         guide_progress = 2,
    --     },
    --     prerequisites = {
    --         "电网教学",
    --     },
	-- },

    {
        name = "",
		narrative = {
            {"哔哩..将获得{/color:4bd0ff 采矿机}放入{/g 指挥中心}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "放置资源",
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
            {"哔哩..分别在{/color:4bd0ff 三处}矿点修建{/g 采矿机}准备开采矿物..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "矿区搭建",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "放置资源",
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
            {"哔哩..{/color:4bd0ff 组装机}设置配方{/g 轻质石砖}进行生产..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "生产设置",
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
            {"哔哩..我们使用{/color:4bd0ff 组装机}生产一些{/g 轻质石砖}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "生产轻质石砖",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "仓库互转",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..检查新{/color:4bd0ff 废墟}并拾取{/g 太阳能板}并记得放置入{/g 指挥中心}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
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
            {"哔哩..放置{/color:4bd0ff 1个}{/g 轻型太阳能板}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
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

    {
        name = "",
		narrative = {
            {"哔哩..使用{/color:4bd0ff 熔炼炉}生产一些{/g 铁板}..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "铁板生产",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "蓄电池铺设",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..有了{/color:4bd0ff 铁板}我们可以生产{/g 轻型太阳能板}..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "太阳能板制造",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "铁板生产",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..因为{/color:4bd0ff 用电设施}增多，基地发电量不足，我们铺设{/g 轻型太阳能板}提高发电量..哔哩", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "太阳能发电",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "太阳能板制造",
        },
	},

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
            {"哔哩..先放置{/g 锅炉}做发电准备..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "锅炉放置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "发电机获取",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..前往{/color:4bd0ff 锅炉}进行{/g 卤水沸腾}的工作准备..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "锅炉设置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "锅炉放置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..放置{/g 地下水挖掘机}连接{/color:4bd0ff 锅炉}的对应{/color:4bd0ff 液口}进行原料输送..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "地下水挖掘机放置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "锅炉设置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..放置{/g 蒸汽发电机}连接{/color:4bd0ff 锅炉}的对应{/color:4bd0ff 液口}接收蒸汽发电..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "发电机放置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "地下水挖掘机放置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..现在电力充足，请前往{/color:4bd0ff 组装机}生产{/g 地质科技包}为科学研究进行准备..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "生产科技包",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "发电机放置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..{/color:4bd0ff 地质科技包}准备完毕，现在开始科技研究..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "启动科技研究",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "生产科技包",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..恭喜你结束了{/g 电网教学}..哔哩..(高兴)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            pop_chapter = {"/pkg/vaststars.resources/ui/tutorial_end.html", {text = "电网教学结束"}},
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