local guide = {
	{
        name = "guide-1",
		narrative = {
            {"哔哩..哔哗..已迫降在代号P4031的星球。星球未发现生命迹象..(失望)", "textures/guide/guide-1.texture"},
            {"哔哩..哔哗..启动大气分析协议中..缺少氧气..(失望)"},
            {"哔哩..哔哗..启动地质分析协议中..铁铝丰富..(轻松)"},
            {"哔哩..哔哗..启动生存可靠性分析..0.04565%存活概率..(情绪表达跳过中)"},
            {"博士，作为助理AI，我建议你立刻开始工作..哔哩..你的剩余生存时间理论上只有348.26地球小时..(担忧)", "textures/guide/guide-4.texture"},
            {"迫降并不算太糟糕，指挥中心结构完整。我们先清理周边残骸，兴许能找到一些有用的物资..(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            pop_chapter = {"序章","迫降P4031"},
            task = {
                "清除废墟",
            },
            visible_value = 5,
        },
        prerequisites = {},
	},

    {
        name = "guide-2",
		narrative = {
            {"看来我们捡到了不少有价值的破烂..哔哩..物资。科技就是第一生产力，让我们建造一所科研中心..(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            visible_value = 10,
            task = {
            }
        },
        prerequisites = {
            "清除废墟",
        },
	},
}

return guide