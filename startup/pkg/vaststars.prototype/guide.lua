local guide = {
	{
        name = "guide-1",
		narrative = {
            {"哔哩..哔哗..已迫降在{/g 代号P4031}的星球。尚未发现任何生命迹象..(失望)", "textures/guide/guide-6.texture"},
            {"哔哩..哔哗..哔哩..启动大气分析协议中..P4031{/g 缺少氧气}..(失望)"},
            {"哔哩..哔哗..哔哩..启动地质分析协议中..P4031{/g 铁铝丰富}..(轻松)","textures/guide/guide-1.texture"},
            {"哔哩..哔哗..启动生存可靠性分析..{/g 0.04565%}存活概率..(情绪表达跳过中)","textures/guide/guide-4.texture"},
    
        },
        narrative_end = {
            task = {
                "迫降火星",
            },
            guide_progress = 10,
        },
        prerequisites = {},
	},
	{
        name = "guide-2",
		narrative = {
            {"作为助理AI，我建议你立刻开始工作..哔哩..你的剩余生存时间理论上只有{/g 348.26}地球小时..(担忧)", "textures/guide/guide-6.texture"},
            {"哔哩..发现可用{/g 无人机仓库}和{/g 废墟}..哔哩..引导无人机搬运有用物资..哔哩..(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            pop_chapter = {"序章","迫降P4031"},
            task = {
                "管理仓库",
            },
            guide_progress = 10,
        },
        prerequisites = {"迫降火星"},
	},


    {
        name = "guide-3",
		narrative = {
            {"哔哩..无人机真是听话的机器..请操作附近的{/g 建造中心}建造{/g 采矿机}..(期待)", "textures/guide/guide-6.texture"},
        },
        narrative_end = {
            -- pop_chapter = {"第一阶段","物流网络"},
            guide_progress = 10,
            task = {
                "建造采矿机",
            }
        },
        prerequisites = {
            "管理仓库",
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
        name = "guide-4",
		narrative = {
            {"哔哩..采矿机顺利建造完毕..石矿采集技术可行性为99.983%..哔哩..(期待)", "textures/guide/guide-2.texture"},
            {"哔哩..请将采矿机放置在石矿位置，开始采集石矿..哔哩..(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "放置采矿机",
            }
        },
        prerequisites = {
            "建造采矿机",
        },
	},


    {
        name = "guide-5",
		narrative = {
            {"哔哩..发现目前采矿机处于断电状态，无法正常工作..哔哩..哔哗..(失望)", "textures/guide/guide-6.texture"},
            {"哔哩..请使用建造中心生产足够电线杆..哔哩..哔哗..(期待)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "建造电线杆",
            }
        },
        prerequisites = {
            "放置采矿机",
        },
	},

    {
        name = "guide-6",
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
            "建造电线杆",
        },
	},

    {
        name = "guide-7",
		narrative = {
            {"哔哩..采矿机顺利工作了，储藏石矿需要新的无人机仓库，请在建造中心生产更多无人机仓库..哔哩(期待)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "建造无人机仓库",
            }
        },
        prerequisites = {
            "放置电线杆",
        },
	},


    {
        name = "guide-8",
		narrative = {
            {"哔哩..将新建的无人机仓库放置在石矿采矿机旁边，这样我们就可以等会采集矿石了....(轻松)", "textures/guide/guide-1.texture"},
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "放置无人机仓库",
            }
        },
        prerequisites = {
            "建造无人机仓库",
        },
	},


    {
        name = "guide-9",
		narrative = {
            {"哔哩..矿物采集进展非常顺利，存活概率大幅提升至0.3244%！..(期待)", "textures/guide/guide-2.texture"},
            {"勤劳的无人机平台再次上线..选择运输{/g 碎石}就可以开始工作了(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "生产碎石矿",
            }
        },
        prerequisites = {
            "放置无人机仓库",
        },
	},

    {
        name = "guide-10",
		narrative = {
            {"采集P4031地质样本制造{/g 科技包}..哔哩..我们就能更好地研究星球地质结构。", "textures/guide/guide-2.texture"},
            {"P4031蕴含丰富的矿藏..哔哩..先用{/g 采矿机}挖掘铁矿和石矿资源..开工开工..(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "放置科研中心",
            }
        },
        prerequisites = {
            "生产碎石矿",
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
        name = "guide-11",
		narrative = {
            {"{/g 组装机}可使用3D打印技术制造地质科技包..哔哩..哔哗..请求建造{/g 组装机}..(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            pop_chapter = {"第一章","自动生产"},
            guide_progress = 30,
            task = {
                "地质研究",
            }
        },
        prerequisites = {
            "放置科研中心",
        },
	},

    {
        name = "guide-12",
		narrative = {
            {"这个星球蕴含丰富的铁矿，将{/g 铁}从中提炼出来就能成为我们工业原料..哔哩..哔哗..(期待)", "textures/guide/guide-2.texture"},
            {"好好利用这个星球的资源，我们的生存概率将会提高至{/g 0.3244%}..哔哩..哔哗..(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
                "铁矿熔炼",
            }
        },
        prerequisites = {
            "基地生产1",
        },
	},


    {
        name = "guide-13",
		narrative = {
            {"{/g 铁矿熔炼}研究顺利完成..哔哩..我们掌握了生产{/g 铁板}的工艺..哔哗..(期待)", "textures/guide/guide-2.texture"},
            {"{/g 熔炼炉}可以帮助我们处理铁矿，让我们开始建造吧..哔哩..哔哗..(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
                "放置熔炼炉",
            }
        },
        prerequisites = {
            "铁矿熔炼",
        },
	},

    {
        name = "guide-14",
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
        name = "guide-15",
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
        name = "guide-16",
		narrative = {
            {"我们具备了提取空气中有用气体的能力..哔哩..(兴奋)", "textures/guide/guide-2.texture"},
            {"很多稀有气体可以用于工业生产，让我们开始研究{/g 空气分离}吧..哔哩..哔哩(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
                "空气分离",
            }
        },
        prerequisites = {
            "维修破损组装机",
            "电解",
        },
	},

    {
        name = "guide-17",
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
        name = "guide-18",
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
        name = "guide-19",
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