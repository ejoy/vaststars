local guide = {
	{
        name = "guide-1",
		narrative = {
            {"哔哩..哔哗..已迫降在{/g 代号P4031}的星球。尚未发现任何生命迹象..(失望)", "textures/guide/guide-6.texture"},
            {"哔哩..哔哗..哔哩..启动大气分析协议中..P4031{/g 缺少氧气}..(失望)"},
            {"哔哩..哔哗..哔哩..启动地质分析协议中..P4031{/g 铁铝丰富}..(轻松)","textures/guide/guide-1.texture"},
            {"哔哩..哔哗..启动生存可靠性分析..{/g 0.04565%}存活概率..(情绪表达跳过中)","textures/guide/guide-4.texture"},
            {"博士，作为助理AI，我建议你立刻开始工作..哔哩..你的剩余生存时间理论上只有{/g 348.26}地球小时..(担忧)", "textures/guide/guide-6.texture"},
            {"哔哩..发现道路阻断..哔哩..建议{/g 修复道路}..哔哩..(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            pop_chapter = {"序章","迫降P4031"},
            task = {
                "修复阻断公路",
            },
            guide_progress = 10,
        },
        prerequisites = {},
	},


    {
        name = "guide-2",
		narrative = {
            {"缺少高效的物流运输最多维持{/g 374.09}地球小时的生存..哔哩..(担忧)", "textures/guide/guide-6.texture"},
            {"不过我们在废墟中发现了保存完好的{/g 物流中心}，物流中心可以高效开展物流运输..哔哩..(兴奋)", "textures/guide/guide-3.texture"},
            {"让我们在道路边赶紧修建一座{/g 物流中心}..哔哩..(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            -- pop_chapter = {"第一阶段","物流网络"},
            guide_progress = 10,
            task = {
                "放置物流中心",
            }
        },
        prerequisites = {
            "修复阻断公路",
        },
	},

    -- {
    --     name = "guide-2",
	-- 	narrative = {
    --         {"哔哩..发现道路阻断..哔哩..建议{/g 修复道路}..哔哩..(期待)", "textures/guide/guide-2.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 10,
    --         task = {
    --             "修复阻断公路",
    --         }
    --     },
    --     prerequisites = {
    --         "清除废墟",
    --     },
	-- },

    {
        name = "guide-3",
		narrative = {
            {"我们捡到了不少有价值的破烂..哔哩..物资。科技就是第一生产力，建议先{/g 建造一所科研中心}..(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "放置科研中心",
            }
        },
        prerequisites = {
            "放置物流中心",
        },
	},

    {
        name = "guide-4",
		narrative = {
            {"哔哩..整个基地的用电设施都需要被{/g 电网覆盖}，否则它们将无法工作..哔哩(无奈）", "textures/guide/guide-6.texture"},
            {"指挥中心可产生电力..哔哩..{/g 放置电线杆}把指挥中心的电力扩散出去..哔哩(期待)", "textures/guide/guide-3.texture"},
            {"当电线杆之间出现{/r 红色电线}时则表示成功连接，在电线{/color:4bd0ff 蓝色范围}内就会有电力传输(兴奋)", "textures/guide/guide-3.texture"},
            {"若指挥中心和电线杆形成一个{/g 电网}，处于{/g 电网}内的用电设施就可以工作了..哔哩(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "放置电线杆",
            }
        },
        prerequisites = {
            "放置科研中心",
        },
	},


    {
        name = "guide-5",
		narrative = {
            {"哔哩..我们终于恢复了研究能力..哔哩..目前{/g 存活概率}提升为0.07672%..(轻松)", "textures/guide/guide-1.texture"},
            {"哔哩..让我们点击{/g 研究中心}按钮，开始研究第一个科技..(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 15,
            task = {
            }
        },
        prerequisites = {
            "放置电线杆",
        },
	},


    {
        name = "guide-6",
		narrative = {
            {"采集P4031地质样本制造{/g 科技包}..哔哩..我们就能更好地研究星球地质结构。", "textures/guide/guide-2.texture"},
            {"P4031蕴含丰富的矿藏..哔哩..先用{/g 采矿机}挖掘铁矿和石矿资源..开工开工..(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 20,
            task = {
                "放置采矿机",
            }
        },
        prerequisites = {
            "地质研究",
        },
	},

    -- {
    --     name = "guide-8",
	-- 	narrative = {
    --         {"哔哩..哔哩..矿物采集进展非常顺利，{/g 存活概率}大幅提升至0.3244%！(兴奋)", "textures/guide/guide-3.texture"},
    --         {"哔哩..指挥中心有{/g 制造舱}，可以生产简单物件..请使用制造舱生产几个{/g 地质科技包}..哔哩(期待)", "textures/guide/guide-2.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 25,
    --         task = {
    --             "制造舱生产",
    --         }
    --     },
    --     prerequisites = {
    --         "转运铁矿石",
    --         "转运碎石矿",
    --     },
	-- },

    {
        name = "guide-7",
		narrative = {
            {"{/g 组装机}可使用3D打印技术制造地质科技包..哔哩..哔哗..请求建造{/g 组装机}..(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            pop_chapter = {"第一章","自动生产"},
            guide_progress = 30,
            task = {
                "放置组装机",
            }
        },
        prerequisites = {
            "生产铁矿石",
            "生产碎石矿",
        },
	},


    {
        name = "guide-8",
		narrative = {
            {"哔哩..哔哗..基地开始采集气液资源，{/g 管道}正是运输此类资源的关键..(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
                "生产管道",
            }
        },
        prerequisites = {
            "管道系统1",
        },
	},

    {
        name = "guide-9",
		narrative = {
            {"合理的铺设管道让液体运输更加高效...哔哩..注意管道和机器液口的连接，耐心..和眼神..是关键(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
            }
        },
        prerequisites = {
            "生产管道",
        },
	},

    {
        name = "guide-10",
		narrative = {
            {"{/g 基建站}允许在更远的区域修建建筑，基建站可将建筑材料运送到在覆盖区域..哔哩..(兴奋)", "textures/guide/guide-2.texture"},
            {"为了扩建我们的基地，准备放置{/g 基建站}吧..哔哩..哔哩(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
                "放置基建站",
            }
        },
        prerequisites = {
            "基地生产1",
        },
	},

    {
        name = "guide-11",
		narrative = {
            {"{/g 化工厂}准备就绪，让我们正式进入化工生产..哔哩..哔哩..(兴奋）", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            pop_chapter = {"第二阶段","化工生产"},
            guide_progress = 30,
            task = {
                "放置化工厂",
            }
        },
        prerequisites = {
            "维修化工厂",
        },
	},

    {
        name = "guide-12",
		narrative = {
            {"{/g 塑料}可制造更多精密元件，掌握这种新材料，存活概率提升为1.2923%..哔哩(兴奋）", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
                "生产塑料",
            }
        },
        prerequisites = {
            "生产乙烯",
        },
	},

    {
        name = "guide-13",
		narrative = {
            {"终于可以研制机械装置进入自动化生产，这可以大大提高效率..哔哩..和放松你的手臂..哔哩(期待）", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
                "生产机械科技包",
            }
        },
        prerequisites = {
            "机械研究",
        },
	},

}

return guide